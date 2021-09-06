# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "nhs_api_client/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "nhs_api_client"
  spec.version     = NHSApiClient::VERSION
  spec.authors     = ["Airslie Ltd"]
  spec.email       = ["dev@airslie.com"]
  spec.homepage    = "https://github.com/airslie/nhs_api_client"
  spec.summary     = "A ruby client for NHS APIs"
  spec.description = "A ruby client for NHS APIs"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  spec.add_dependency "httparty", "~> 0.16"
  spec.add_dependency "rails", "> 5.2.4", "< 6.1"
end
