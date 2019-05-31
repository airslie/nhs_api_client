# frozen_string_literal: true

require "nhs_api_client/railtie"

module NHSApiClient
  module Organisations
    class Client
      include HTTParty
      BASE_URL = "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations"
      FIRST_PAGE_URLS = {
        practices: "#{BASE_URL}?PrimaryRoleId=RO177&Limit=100",
        branch_surgeries: "#{BASE_URL}?PrimaryRoleId=RO96&Limit=100"
      }.freeze

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
            break if item_count >= 100
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
