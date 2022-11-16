module WebhookEvent
  class Error < StandardError
    attr_reader :message

    attr_accessor :response

    attr_reader :code
    attr_reader :error
    attr_reader :http_body
    attr_reader :http_headers
    attr_reader :http_status
    attr_reader :json_body # equivalent to #data
    attr_reader :request_id

    def initialize(message = nil, http_status: nil, http_body: nil,
                   json_body: nil, http_headers: nil, code: nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers || {}
      @idempotent_replayed = @http_headers["idempotent-replayed"] == "true"
      @json_body = json_body
      @code = code
      @request_id = @http_headers["request-id"]
      @error = construct_error_object
    end

    def construct_error_object
      return nil if @json_body.nil? || !@json_body.key?(:error)

      ErrorObject.construct_from(@json_body[:error])
    end

    def idempotent_replayed?
      @idempotent_replayed
    end

    def to_s
      status_string = @http_status.nil? ? "" : "(Status #{@http_status}) "
      id_string = @request_id.nil? ? "" : "(Request #{@request_id}) "
      "#{status_string}#{id_string}#{@message}"
    end  
  end

  class UnauthorizedError < Error; end
  class ProcessError < Error; end

  class SignatureVerificationError < Error
    attr_accessor :sig_header

    def initialize(message, sig_header, http_body: nil)
      super(message, http_body: http_body)
      @sig_header = sig_header
    end
  end
end