require "coveralls"
Coveralls.wear!

require "webmock/rspec"
require File.expand_path("../../lib/webhook_event", __FILE__)

Dir[File.expand_path("../spec/support/**/*.rb", __FILE__)].each { |file| require file }

RSpec.configure do |config|
  config.order = "random"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    @signing_secrets = WebhookEvent.signing_secrets
    @event_filter = WebhookEvent.event_filter
    @notifier = WebhookEvent.backend.notifier
    WebhookEvent.backend.notifier = @notifier.class.new
  end

  config.after do
    WebhookEvent.signing_secrets = @signing_secrets
    WebhookEvent.event_filter = @event_filter
    WebhookEvent.backend.notifier = @notifier
  end
end