# frozen_string_literal: true

RSpec.describe MqttToGpio::Server do
  describe "#run!" do
    it "initializes watchers with input configuration" do
      configuration = {
        "inputs" => [
          { "pin" => 1, "name" => "input1", "hold" => 200 },
          { "pin" => 2, "name" => "input2" }
        ],
        "outputs" => [],
        "mqtt" => {
          "host" => "mqtt.example.com",
          "topic_prefix" => "home"
        }
      }

      stubbed_watcher = instance_double(MqttToGpio::Watcher, run!: nil)
      allow(MqttToGpio::Watcher).to receive(:new).and_return(stubbed_watcher)

      server = MqttToGpio::Server.new(configuration)
      server.run!

      expect(MqttToGpio::Watcher).to have_received(:new).with(pin: 1, name: "input1", hold: 200, publisher: anything)
      expect(MqttToGpio::Watcher).to have_received(:new).with(pin: 2, name: "input2", hold: false, publisher: anything)
    end

    it "initializes listener with output configuration" do
      configuration = {
        "inputs" => [],
        "outputs" => [
          { "pin" => 1, "name" => "input1" },
          { "pin" => 2, "name" => "input2" }
        ],
        "mqtt" => {
          "host" => "mqtt.example.com",
          "topic_prefix" => "home"
        }
      }

      stubbed_watcher = instance_double(MqttToGpio::Listener, run!: nil)
      allow(MqttToGpio::Listener).to receive(:new).and_return(stubbed_watcher)

      server = MqttToGpio::Server.new(configuration)
      server.run!

      expect(MqttToGpio::Listener).to have_received(:new).with(
        host: "mqtt.example.com",
        port: nil,
        username: nil,
        password: nil,
        topic_prefix: "home",
        handler: instance_of(MqttToGpio::Handler)
      )
    end
  end
end
