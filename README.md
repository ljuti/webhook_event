# WebhookEvent

WebhookEvent is a Rails engine for receiving webhooks into your Rails applications. It has been extracted from [StripeEvent](https://github.com/integrallis/stripe_event) and [Stripe](https://github.com/stripe/stripe-ruby) gems into a generic webhook engine.

Like [StripeEvent](https://github.com/integrallis/stripe_event), it is built on the [ActiveSupport::Notifications API](http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html). Incoming webhook requests are authenticated with the webhook signatures.

In your Rails app, you'll define subscribers to handle specific event types. Subscribers can be a block or an object that responds to `#call`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "webhook_event"
```

And then execute:
```bash
$ bundle
```

Then mount the engine:
```ruby
# config/routes.rb
Rails.application.routes.draw do
  mount WebhookEvent::Engine, at: "/webhooks" # or any other path you choose
end
```

## Usage
Set up a signing secret for webhooks
```ruby
WebhookEvent.signing_secret = Rails.application.credentials.dig(:webhooks, :signing_secret)
```

You can even have multiple secrets if you wish
```ruby
WebhookEvent.signing_secrets = [
  Rails.application.credentials.dig(:webhooks, :secrets, :app_one),
  Rails.application.credentials.dig(:webhooks, :secrets, :app_two)
]
```

Set up the configuration in an initializer
```ruby
# config/initializers/webhooks.rb
WebhookEvent.configure do |events|
  events.subscribe "account.destroyed" do |event|
    event.class       # => WebhookEvent::Event
    event.type        # => "account.destroyed"
    event.data        # => Hash with your event data
  end

  events.all do |event|
    # Handle all events
  end
end
```

### Subscriber objects that respond to `#call`

```ruby
class AccountCreatedHandler
  def call(event)
    # handle the event
  end
end
```

```ruby
WebhookEvent.configure do |events|
  events.subscribe "account.created", AccountCreatedHandler.new
end
```

### Subscribing to a namespace of event types

```ruby
WebhookEvent.configure do |events|
  events.subscribe "account." do |event|
    # will be triggered for all "account.*" events
  end

  events.subscribe "invoice.charges.*" do |event|
    # will be triggered for all "invoice.charges.*" events
  end
end
```

## Securing your webhook endpoint

### Authenticating webhooks with signatures

The library expects cryptographically signed webhook payloads with a signature that is included in a special header of the incoming request. By verifying the signature, you ensure that the request is properly authenticated and originates from a party holding the signing secret.

### Support for multiple signing secrets

It's possible to configure an array of signing secrets using the `signing_secrets` configuration option. The first one that successfully matches will be used to verify the incoming webhook request and the event.

```ruby
WebhookEvent.signing_secrets = [
  Rails.application.credentials.dig(:webhooks, :secrets, :app_one),
  Rails.application.credentials.dig(:webhooks, :secrets, :app_two)
]
```

## Roadmap

[ ] Separate webhook request capture and handling behavior
[ ] Request log repository
[ ] Replay ability for handler failures
[ ] Adapters for multiple data stores

## Credits
[Integrallis Software](https://github.com/integrallis) and all the [contributors](https://github.com/integrallis/stripe_event/graphs/contributors) for their work on [StripeEvent](https://github.com/integrallis/stripe_event).

[Stripe](https://github.com/stripe) for their work on [stripe-ruby](https://github.com/stripe/stripe-ruby).

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
