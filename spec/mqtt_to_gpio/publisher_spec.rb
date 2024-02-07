# frozen_string_literal: true

RSpec.describe MqttToGpio::Publisher do
  describe "#publish_state" do
    it "publishes an ON message" do
      publisher = MqttToGpio::Publisher.new(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic_prefix: "home"
      )

      stubbed_mqtt_client = instance_double("MQTT::Client")
      allow(MQTT::Client).to receive(:connect).and_yield(stubbed_mqtt_client)
      allow(stubbed_mqtt_client).to receive(:publish)

      publisher.publish_state("device1", "1")

      expect(MQTT::Client).to have_received(:connect).with(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password"
      )

      expect(stubbed_mqtt_client).to have_received(:publish).with("home/input/device1", { state: "ON" }.to_json)
    end

    it "publishes an OFF message" do
      publisher = MqttToGpio::Publisher.new(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic_prefix: "home"
      )

      stubbed_mqtt_client = instance_double("MQTT::Client")
      allow(MQTT::Client).to receive(:connect).and_yield(stubbed_mqtt_client)
      allow(stubbed_mqtt_client).to receive(:publish)

      publisher.publish_state("device1", "0")

      expect(MQTT::Client).to have_received(:connect).with(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password"
      )

      expect(stubbed_mqtt_client).to have_received(:publish).with("home/input/device1", { state: "OFF" }.to_json)
    end
  end

  describe "#publish_hold" do
    it "publishes a HOLD message" do
      publisher = MqttToGpio::Publisher.new(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password",
        topic_prefix: "home"
      )

      stubbed_mqtt_client = instance_double("MQTT::Client")
      allow(MQTT::Client).to receive(:connect).and_yield(stubbed_mqtt_client)
      allow(stubbed_mqtt_client).to receive(:publish)

      publisher.publish_hold("device1", 3)

      expect(MQTT::Client).to have_received(:connect).with(
        host: "mqtt.example.com",
        port: 1883,
        username: "user",
        password: "password"
      )

      expect(stubbed_mqtt_client)
        .to have_received(:publish).with("home/input/device1", { state: "HOLD", hold_count: 3 }.to_json)
    end
  end
end
