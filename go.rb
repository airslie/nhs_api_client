# frozen_string_literal: true

#
# An example script for iterating through organisations - in this case just practices.
#

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "rails"
  gem "nhs_api_client", path: "."
end

client = NHSApiClient::Organisations::Client.new

roles = %i(practices) # also e.g. branch_surgeries

# Fetch each page
client.fetch_pages(roles: roles, last_change_date: nil) do |page|
  # For each organisation in the page..
  page.items.each do |item|
    # Output it's name...
    puts item.name
    # ...then implicity fetch its extended details from another url so we can get the tel no.
    puts "  Tel: #{item.details.tel}"
  end
  puts "#{page.offset + page.item_count} of #{page.total_count}"
end
