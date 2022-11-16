module WebhookEvent
  module Signature
    EXPECTED_SCHEME = "v1"

    # Computes a webhook signature given a time (probably the current time),
    # a payload, and a signing secret.
    def self.compute_signature(timestamp, payload, secret)
      raise ArgumentError, "timestamp should be an instance of Time" \
        unless timestamp.is_a?(Time)
      raise ArgumentError, "payload should be a string" \
        unless payload.is_a?(String)
      raise ArgumentError, "secret should be a string" \
        unless secret.is_a?(String)

      timestamped_payload = "#{timestamp.to_i}.#{payload}"
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha256"), secret,
                              timestamped_payload)
    end

    # Generates a value that would be added to a `WebhookEvent-Signature` for a
    # given webhook payload.
    #
    # Note that this isn't needed to verify webhooks in any way, and is
    # mainly here for use in test cases (those that are both within this
    # project and without).
    def self.generate_header(timestamp, signature, scheme: EXPECTED_SCHEME)
      raise ArgumentError, "timestamp should be an instance of Time" \
        unless timestamp.is_a?(Time)
      raise ArgumentError, "signature should be a string" \
        unless signature.is_a?(String)
      raise ArgumentError, "scheme should be a string" \
        unless scheme.is_a?(String)

      "t=#{timestamp.to_i},#{scheme}=#{signature}"
    end

    # Extracts the timestamp and the signature(s) with the desired scheme
    # from the header
    def self.get_timestamp_and_signatures(header, scheme)
      list_items = header.split(/,\s*/).map { |i| i.split("=", 2) }
      timestamp = Integer(list_items.select { |i| i[0] == "t" }[0][1])
      signatures = list_items.select { |i| i[0] == scheme }.map { |i| i[1] }
      [Time.at(timestamp), signatures]
    end
    private_class_method :get_timestamp_and_signatures

    def self.secure_compare(str_a, str_b)
      return false unless str_a.bytesize == str_b.bytesize

      l = str_a.unpack "C#{str_a.bytesize}"

      res = 0
      str_b.each_byte { |byte| res |= byte ^ l.shift }
      res.zero?
    end

    # Verifies the signature header for a given payload.
    #
    # Raises a SignatureVerificationError in the following cases:
    # - the header does not match the expected format
    # - no signatures found with the expected scheme
    # - no signatures matching the expected signature
    # - a tolerance is provided and the timestamp is not within the
    #   tolerance
    #
    # Returns true otherwise
    def self.verify_header(payload, header, secret, tolerance: nil)
      begin
        timestamp, signatures =
          get_timestamp_and_signatures(header, EXPECTED_SCHEME)

      # TODO: Try to knock over this blanket rescue as it can unintentionally
      # swallow many valid errors. Instead, try to validate an incoming
      # header one piece at a time, and error with a known exception class if
      # any part is found to be invalid. Rescue that class here.
      rescue StandardError
        raise SignatureVerificationError.new(
          "Unable to extract timestamp and signatures from header",
          header, http_body: payload
        )
      end

      if signatures.empty?
        raise SignatureVerificationError.new(
          "No signatures found with expected scheme #{EXPECTED_SCHEME}",
          header, http_body: payload
        )
      end

      expected_sig = compute_signature(timestamp, payload, secret)
      unless signatures.any? { |s| secure_compare(expected_sig, s) }
        raise SignatureVerificationError.new(
          "No signatures found matching the expected signature for payload",
          header, http_body: payload
        )
      end

      if tolerance && timestamp < Time.now - tolerance
        raise SignatureVerificationError.new(
          "Timestamp outside the tolerance zone (#{Time.at(timestamp)})",
          header, http_body: payload
        )
      end

      true
    end
  end
end