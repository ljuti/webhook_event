module WebhookEvent
  module Webhook
    DEFAULT_TOLERANCE = 300

    # Initializes an Event object from a JSON payload.
    #
    # This may raise JSON::ParserError if the payload is not valid JSON, or
    # SignatureVerificationError if the signature verification fails.
    def self.construct_event(payload, sig_header, secret,
                             tolerance: DEFAULT_TOLERANCE)
      Signature.verify_header(payload, sig_header, secret, tolerance: tolerance)

      # It's a good idea to parse the payload only after verifying it. We use
      # `symbolize_names` so it would otherwise be technically possible to
      # flood a target's memory if they were on an older version of Ruby that
      # doesn't GC symbols. It also decreases the likelihood that we receive a
      # bad payload that fails to parse and throws an exception.
      data = JSON.parse(payload, symbolize_names: true)
      Event.new(data)
    end
  end
end