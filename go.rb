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

# Fetch each page
client.fetch_pages(roles: :practices, last_change_date: "2019-05-25", page_size: 5,
                   quit_after: 6) do |page|
  # For each organisation in the page..
  page.items.each do |item|
    # Output it's name...
    puts item.name
    # ...then implicity fetch its extended details from another url so we can get the tel no.
    # puts "  Tel: #{item.details.tel}"
  end
  puts "#{page.offset + page.item_count} of #{page.total_count}"
end
