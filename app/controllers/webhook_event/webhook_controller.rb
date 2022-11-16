module WebhookEvent
  class WebhookController < ActionController::Base
    if Rails.application.config.action_controller.default_protect_from_forgery
      skip_before_action :verify_authenticity_token
    end

    def event
      WebhookEvent.instrument(verified_event)
      head :ok
    rescue WebhookEvent::SignatureVerificationError => exception
      log_error(exception)
      head :bad_request
    rescue WebhookEvent::ProcessError
      head :unprocessable_entity
    end

    private

    def verified_event
      payload = request.body.read
      signature = request.headers["WebhookEvent-Signature"]
      possible_secrets = secrets(payload, signature)

      possible_secrets.each_with_index do |secret, idx|
        begin
          return WebhookEvent::Webhook.construct_event(payload, signature, secret.to_s)
        rescue WebhookEvent::SignatureVerificationError => exception
          raise if idx == possible_secrets.length - 1
          next
        end
      end
    end

    def secrets(payload, signature)
      return WebhookEvent.signing_secrets if WebhookEvent.signing_secret
      raise WebhookEvent::SignatureVerificationError.new(
        "Cannot verify signatures without `WebhookEvent.signing_secret`",
        signature, http_body: payload
      )
    end

    def log_error(exception)
      logger.error exception.message
      exception.backtrace.each { |line| logger.error "  #{line}" }
    end

  end
end