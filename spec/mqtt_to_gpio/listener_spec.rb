# frozen_string_literal: true

RSpec.describe MqttToGpio::Listener do
  describe "#run!" do
    it "listens for MQTT messages" do
      handler = instance_double("MqttToGpio::Handler")

      listener = MqttToGpio::Listener.new(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic_prefix: "home",
        handler: handler
      )

      stubbed_listener = instance_double("MqttToGpio::Mqtt::Listener")
      allow(MqttToGpio::Mqtt::Listener).to receive(:new).and_return(stubbed_listener)
      allow(stubbed_listener).to receive(:listen).and_yield("home/output/device1/set", "device1", "1")
      allow(handler).to receive(:handle_message)

      listener.run!

      expect(MqttToGpio::Mqtt::Listener).to have_received(:new).with(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic: "home/output/#/set"
      )

      expect(stubbed_listener).to have_received(:listen)
      expect(handler).to have_received(:handle_message).with("device1", "1")
    end
  end
end
