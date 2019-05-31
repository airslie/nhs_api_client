# frozen_string_literal: true

# A page of organisation results from the API
class Page
  attr_reader :next_url, :items, :total_count, :item_count, :limit, :offset

  def initialize(response)
    items_hash = JSON.parse(response.body, symbolize_names: true)
    @items = items_hash[:Organisations].map do |item_hash|
      Item.new(item_hash)
    end
    @next_url = response.headers["next-page"]
    @total_count = response.headers["x-total-count"].to_i
    @item_count = response.headers["returned-records"].to_i
    @limit = URI.decode_www_form(response.request.last_uri.query).to_h.fetch("Limit").to_i
    @offset = URI.decode_www_form(response.request.last_uri.query).to_h["Offset"].to_i
  end

  def self.next(url)
    response = HTTParty.get(url, format: :json)
    Page.new(response)
  end

  def next
    Page.next(next_url)
  end
end
