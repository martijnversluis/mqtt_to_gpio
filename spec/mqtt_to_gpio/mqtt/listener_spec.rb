# frozen_string_literal: true

RSpec.describe MqttToGpio::Mqtt::Listener do
  describe "#listen" do
    it "yields the topic, device_id and message" do
      listener = MqttToGpio::Mqtt::Listener.new(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic: "home/output/#/set"
      )

      stubbed_mqtt_client = instance_double("MQTT::Client")
      allow(MQTT::Client).to receive(:connect).and_yield(stubbed_mqtt_client)
      allow(stubbed_mqtt_client).to receive(:subscribe)
      allow(stubbed_mqtt_client).to receive(:get).and_yield("home/output/device1/set", "1")

      listener.listen do |topic, device_id, message|
        expect(topic).to eq "home/output/device1/set"
        expect(device_id).to eq "device1"
        expect(message).to eq "1"
      end

      expect(MQTT::Client).to have_received(:connect).with(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password"
      )

      expect(stubbed_mqtt_client).to have_received(:subscribe).with("home/output/#/set")
      expect(stubbed_mqtt_client).to have_received(:get)
    end
  end
end
