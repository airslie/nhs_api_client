# TODO: inject httparty as a http_client
# think about sing methid missing to delegate to parsed_content
# could have Page and Item include a module that uses method_missing to
# trap snakecase attrs, promote to capitalized and then extract from json
# could adda Fragment class to handle eg GeoLoc in same way etc
require "httparty"
# require 'byebug'
# require "attr_extras"

# A page of organisation results from the API
#
class Page
  attr_reader :next_url, :items, :total_count, :item_count, :limit, :offset

  def initialize(response)
    items_hash = JSON.parse(response.body, symbolize_names: true)
    @items = items_hash[:Organisations].map do |item_hash|
      Item.new(item_hash)
    end
    @next_url = response.headers['next-page']
    @total_count = response.headers["x-total-count"].to_i
    @item_count = response.headers["returned-records"].to_i
    @limit = URI::decode_www_form(response.request.last_uri.query).to_h.fetch("Limit").to_i
    @offset = URI::decode_www_form(response.request.last_uri.query).to_h["Offset"].to_i
  end

  def self.next(url)
    response = HTTParty.get(url, format: :json)
    Page.new(response)
  end

  def next
    Page.next(next_url)
  end
end

class PageTheFirst
  attr_reader :next_url

  def initialize(url)
    @next_url = url
  end

  def next
    Page.next(next_url)
  end
end


# An organisation built intially from the item in page.items
# but if item#details is called it will lazily load the extended organisation
# details in another API call.
class Item
  attr_reader :name, :org_id, :last_change_date, :status, :org_link

  def initialize(**args)
    @name = args.fetch(:Name)
    @org_id = args.fetch(:OrgId)
    @last_change_date = args.fetch(:LastChangeDate)
    @status = args.fetch(:Status)
    @org_link = args.fetch(:OrgLink)
  end

  # Fetch organisation details JIT
  def details
    @details ||= fetch_details
  end

  def fetch_details
    response = HTTParty.get(org_link, format: :json)
    org_hash = JSON.parse(response.body, symbolize_names: true)
    ItemDetails.new(org_hash.fetch(:Organisation))
  end
end

# Organisation details loaded from An API call
class ItemDetails
  attr_reader :tel, :addr_ln1, :addr_ln2, :addr_ln3, :town
  attr_reader :county, :post_code, :country

  def initialize(**args)
    build_contacts args[:Contacts]
    build_address args.fetch(:GeoLoc).fetch(:Location)
  end

  # receive [] or e.g. [{:Contact=>[{:type=>"tel", :value=>"01474 369436"}]}]
  def build_contacts(contacts)
    # Generate a structure that is easier to query
    # [{:type=>"tel", :value=>"01484 653326"}, {:type=>"???", :value=>"???"}, ...]
    contacts = Array(contacts).map(&:last).flatten
    @tel = (contacts.find{ |a| a[:type] == "tel" } || {})[:value]
  end

  # Note not all address fields are always present
  def build_address(geo_loc)
    @addr_ln1 = geo_loc[:AddrLn1]
    @addr_ln2 = geo_loc[:AddrLn2]
    @addr_ln3 = geo_loc[:AddrLn3]
    @town = geo_loc[:Town]
    @county = geo_loc[:County]
    @post_code = geo_loc.fetch(:PostCode)
    @country = geo_loc.fetch(:Country)
  end
end

module NhsApi
  module Organisations
    class Client
      include HTTParty
      BASE_URL = "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations"
      FIRST_PAGE_URLS = {
        practices: "#{BASE_URL}?PrimaryRoleId=RO177&Limit=100",
        branch_surgeries: "#{BASE_URL}?PrimaryRoleId=RO96&Limit=100"
      }

      # last_change_date: nil returns all
      def fetch_pages(roles:, **_options)
        Array(roles).each do |role|
          page = start_page_for(role)
          item_count = 0
          loop do
            GC.start # force garbage collection to prevent exessive memory usage
            page = page.next
            item_count += page.item_count
            yield(page) if block_given?
            break if page.next_url.nil?
            break if item_count >= 200
          end
        end
      end

      def start_page_for(role)
        PageTheFirst.new(FIRST_PAGE_URLS.fetch(role))
        # OpenStruct.new(
        #   next_url: FIRST_PAGE_URLS.fetch(role)
        # )
      end
    end
  end
end

client = NhsApi::Organisations::Client.new
roles = %i[practices] # branch_surgeries]
client.fetch_pages(roles: roles, last_change_date: nil) do |page|
  page.items.each do |item|
    item.name
    # item.details.tel
    yield(item) if block_given?
  end
  puts "#{page.offset + page.item_count} of #{page.total_count}"
end
