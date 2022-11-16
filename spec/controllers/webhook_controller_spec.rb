require "rails_helper"
require "spec_helper"

describe WebhookEvent::WebhookController, type: :controller do
  let(:secret_one) { "super-secret-string" }
  let(:secret_two) { "another-secret-string" }

  let(:system_booted) { stub_event("evt_system_booted") }

  def stub_event(identifier)
    JSON.parse(File.read("spec/support/fixtures/#{identifier}.json"))
  end

  def generate_signature(params, secret)
    payload = params.to_json
    timestamp = Time.now

    signer = WebhookEvent::Signature.method(:compute_signature)

    signature =
      if signer.arity == 3
        signer.call(timestamp, payload, secret)
      else
        signer.call("#{timestamp.to_i}.#{payload}", secret)
      end

    "t=#{timestamp.to_i},v1=#{signature}"
  end

  def webhook(signature, params)
    request.env["HTTP_WEBHOOKEVENT_SIGNATURE"] = signature
    request.env["RAW_POST_DATA"] = params.to_json
    post :event, body: params.to_json
  end

  def webhook_with_signature(params, secret = secret_one)
    webhook generate_signature(params, secret), params
  end

  routes { WebhookEvent::Engine.routes }

  context "without a signing secret" do
    before(:each) { WebhookEvent.signing_secret = nil }

    it "denies an invalid signature" do
      webhook "invalid signature", system_booted
      expect(response.code).to eq "400"
    end

    it "denies a valid signature" do
      webhook_with_signature system_booted
      expect(response.code).to eq "400"
    end
  end

  context "with a signing secret" do
    before(:each) { WebhookEvent.signing_secret = secret_one }

    it "denies missing signature" do
      webhook nil, system_booted
      expect(response.code).to eq "400"
    end

    it "denies an invalid signature" do
      webhook "invalid signature", system_booted
      expect(response.code).to eq "400"
    end

    it "denies signature from wrong secret" do
      webhook_with_signature system_booted, secret_two
      expect(response.code).to eq "400"
    end

    it "succeeds with a valid signature" do
      webhook_with_signature system_booted, secret_one
      expect(response.code).to eq "200"
    end
  end
end