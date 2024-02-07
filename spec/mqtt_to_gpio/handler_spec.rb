# frozen_string_literal: true

RSpec.describe MqttToGpio::Handler do
  describe "#handle_message" do
    it "sets the pin to the desired state" do
      handler = MqttToGpio::Handler.new([{ "name" => "device1", "pin" => 17 }])
      stubbed_pin = MqttToGpio::Gpio::Pin.new(17)
      allow(MqttToGpio::Gpio).to receive(:pin).with(17, MqttToGpio::Gpio::OUTPUT).and_yield(stubbed_pin)
      allow(stubbed_pin).to receive(:value=)

      handler.handle_message("device1", "1")

      expect(stubbed_pin).to have_received(:value=).with("1")
    end

    it "logs a warning if the device is unknown" do
      handler = MqttToGpio::Handler.new([])
      allow(MqttToGpio.logger).to receive(:warn)
      allow(MqttToGpio::Gpio).to receive(:pin)

      handler.handle_message("device1", "1")

      expect(MqttToGpio.logger).to have_received(:warn).with("Received message for unknown device: device1")
      expect(MqttToGpio::Gpio).not_to have_received(:pin)
    end
  end
end
