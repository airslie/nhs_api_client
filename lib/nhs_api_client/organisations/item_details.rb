# frozen_string_literal: true

# Organisation details loaded from An API call
class ItemDetails
  attr_reader :tel, :addr_ln1, :addr_ln2, :addr_ln3, :town, :county, :post_code, :country

  def initialize(args = {})
    build_contacts args[:Contacts]
    build_address args.fetch(:GeoLoc).fetch(:Location)
  end

  # receive [] or e.g. [{:Contact=>[{:type=>"tel", :value=>"01474 369436"}]}]
  def build_contacts(contacts)
    # Generate a structure that is easier to query
    # [{:type=>"tel", :value=>"01484 653326"}, {:type=>"???", :value=>"???"}, ...]
    contacts = Array(contacts).map(&:last).flatten
    @tel = (contacts.find { |a| a[:type] == "tel" } || {})[:value]
  end

  # Note not all address fields are always present
  def build_address(geo_loc)
    @addr_ln1 = geo_loc[:AddrLn1]
    @addr_ln2 = geo_loc[:AddrLn2]
    @addr_ln3 = geo_loc[:AddrLn3]
    @town = geo_loc[:Town]
    @county = geo_loc[:County]
    @post_code = geo_loc[:PostCode]
    @country = geo_loc[:Country]
  end
end
