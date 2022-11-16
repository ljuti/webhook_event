require_relative "lib/webhook_event/version"

Gem::Specification.new do |spec|
  spec.name        = "webhook_event"
  spec.version     = WebhookEvent::VERSION
  spec.authors     = ["Lauri Jutila"]
  spec.email       = ["git@laurijutila.com"]
  spec.homepage    = "https://github.com/ljuti/webhook_event"
  spec.summary     = "Webhook event integration for Rails applications."
  spec.description = "Webhook event integration for Rails applications."
  spec.license     = "MIT"
  
  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ljuti/webhook_event"
  spec.metadata["changelog_uri"] = "https://github.com/ljuti/webhook_event/CHANGELOG"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "activesupport", ">= 3.1"
  spec.add_dependency "hashie"

  spec.add_development_dependency "appraisal"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "rails", ">= 7.0.4"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "webmock"
end
