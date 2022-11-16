require "hashie"

module WebhookEvent
  class Event < Hash
    include Hashie::Extensions::MethodAccessWithOverride
  end
end