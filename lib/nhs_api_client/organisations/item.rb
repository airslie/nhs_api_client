# frozen_string_literal: true

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
