# frozen_string_literal: true

require "nhs_api_client/railtie"

module NHSApiClient
  module Organisations
    class Client
      include HTTParty
      BASE_URL = "https://directory.spineservices.nhs.uk/ORD/2-0-0/organisations"\
                 "?PrimaryRoleId=<primary_role_id>"\
                 "&Limit=<page_size>"\
                 "&LastChangeDate=<last_change_date>"
      ROLE_CODES = { practices: "RO177", branch_surgeries: "RO96" }.freeze
      DEFAULT_PAGE_SIZE = 100
      DEFAULT_LAST_CHANGE_DATE = ""

      # quit_after is a kill switch that stops processing when the specificed number of
      # records (not pages) have been found. Useful when debugging to avoid hitting the API
      # excessively. eg quit_after: 10
      # roles can be an array of symbols or just one
      def fetch_pages(roles:, **options)
        Array(roles).each do |role|
          page = PageTheFirst.new(initial_url_for(role, **options))
          quit_after = options[:quit_after].to_i
          item_count = 0
          loop do
            GC.start # force garbage collection to prevent excessive memory usage
            page = page.next
            item_count += page.item_count
            yield(page) if block_given?
            break if page.next_url.nil?
            break if quit_after.positive? && item_count >= quit_after
          end
        end
      end

      private

      # Options:
      # - :last_change_date - if nil it will returns all records
      # - :page_size - the number of practices per page
      def initial_url_for(role, **options)
        last_change_date = options.fetch(:last_change_date, DEFAULT_LAST_CHANGE_DATE)
        page_size = options.fetch(:page_size, DEFAULT_PAGE_SIZE)
        role_code = ROLE_CODES.fetch(role.to_sym)

        BASE_URL
          .gsub("<last_change_date>", last_change_date)
          .gsub("<primary_role_id>", role_code)
          .gsub("<page_size>", page_size.to_s)
      end
    end
  end
end
