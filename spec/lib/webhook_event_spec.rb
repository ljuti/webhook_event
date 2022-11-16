require "spec_helper"

describe WebhookEvent do
  let(:events) { [] }
  let(:subscriber) { ->(event) { events << event } }
  let(:system_failed_event) { WebhookEvent::Event.new(id: "evt_system_failed", type: "system.failed") }
  let(:system_boot_init_event) { WebhookEvent::Event.new(id: "evt_system_boot_init", type: "system.boot.init") }
  let(:system_boot_restart_event) { WebhookEvent::Event.new(id: "evt_system_boot_restart", type: "system.boot.restart") }

  describe "Configuration" do
    it "yields to a block" do
      yielded = nil
      described_class.configure { |events| yielded = events }
      expect(yielded).to eq described_class
    end

    it "requires a block" do
      expect { described_class.configure }.to raise_error ArgumentError
    end
  end

  describe "Subscribing to" do
    describe "a specific type of event" do
      context "with a block subscriber" do
        it "calls the subscriber with the retrieved event" do
          described_class.subscribe("system.failed", &subscriber)
          described_class.instrument(system_failed_event)
          expect(events).to eq [system_failed_event]
        end
      end

      context "with a subscriber that responds to #call" do
        it "calls the subscriber with the retrieved event" do
          described_class.subscribe("system.failed", subscriber)
          described_class.instrument(system_failed_event)
          expect(events).to eq [system_failed_event]
        end
      end
    end

    describe "a namespace of event types" do
      context "with a block subscriber" do
        it "calls the subscriber with the retrieved event" do
          described_class.subscribe("system.boot", &subscriber)

          described_class.instrument(system_boot_init_event)
          described_class.instrument(system_boot_restart_event)

          expect(events).to eq [system_boot_init_event, system_boot_restart_event]
        end
      end

      context "with a subscriber that responds to #call" do
        it "calls the subscriber with the retrieved event" do
          described_class.subscribe("system.boot", subscriber)

          described_class.instrument(system_boot_init_event)
          described_class.instrument(system_boot_restart_event)

          expect(events).to eq [system_boot_init_event, system_boot_restart_event]
        end
      end
    end

    describe "all event types" do
      context "with a block subscriber" do
        it "calls the subscriber with the retrieved event" do
          described_class.all(&subscriber)

          described_class.instrument(system_boot_init_event)
          described_class.instrument(system_boot_restart_event)

          expect(events).to eq [system_boot_init_event, system_boot_restart_event]
        end
      end

      context "with a subscriber that responds to #call" do
        it "calls the subscriber with the retrieved event" do
          described_class.all(subscriber)

          described_class.instrument(system_boot_init_event)
          described_class.instrument(system_boot_restart_event)

          expect(events).to eq [system_boot_init_event, system_boot_restart_event]
        end
      end
    end
  end

  describe "Listening" do
    it "returns true when there's a subscriber for a matching event type" do
      described_class.subscribe("system.", &subscriber)

      expect(described_class.listening?("system.boot")).to be true
      expect(described_class.listening?("system.")).to be true
    end

    it "returns false when there's no subscriber for a matching event type" do
      described_class.subscribe("system.", &subscriber)

      expect(described_class.listening?("account.created")).to be false
      expect(described_class.listening?("account.")).to be false
    end

    it "returns true when there's a subscriber for all event types" do
      described_class.all(&subscriber)

      expect(described_class.listening?("account.")).to be true
      expect(described_class.listening?("system.")).to be true
    end
  end

  describe WebhookEvent::NotificationAdapter do
    let(:adapter) { WebhookEvent.adapter }

    it "calls the subscriber with the last argument" do
      expect(subscriber).to receive(:call).with(:last)

      adapter.call(subscriber).call(:first, :last)
    end
  end

  describe WebhookEvent::Namespace do
    let(:namespace) { WebhookEvent.namespace }

    describe "#call" do
      it "prepends the namespace to a given string" do
        expect(namespace.call("foo.bar")).to eq "webhook_event.foo.bar"
      end

      it "returns the namespace when no arguments are given" do
        expect(namespace.call).to eq "webhook_event."
      end
    end

    describe "#to_regexp" do
      it "matches namespaced strings" do
        expect(namespace.to_regexp("foo.bar")).to match namespace.call("foo.bar")
      end

      it "matches all namespaced strings when no arguments are given" do
        expect(namespace.to_regexp).to match namespace.call("foo.bar")
      end
    end
  end
end
