# frozen_string_literal: true

RSpec.describe MqttToGpio::Watcher do
  describe "#run!" do
    it "initializes watcher with pin, name, hold, and publisher" do
      pin = 1
      name = "input1"
      hold = 200
      publisher = instance_double(MqttToGpio::Publisher)
      stubbed_gpio_pin = instance_double(MqttToGpio::Gpio::Pin, value: MqttToGpio::Gpio::LOW)
      allow(MqttToGpio::Gpio).to receive(:pin).and_yield(stubbed_gpio_pin)

      watcher = MqttToGpio::Watcher.new(pin: pin, name: name, hold: hold, publisher: publisher)
      poller = nil
      allow(watcher).to(receive(:repeat)) { |_interval, &block| poller = block }
      watcher.run!

      expect(MqttToGpio::Gpio).to have_received(:pin).with(pin, MqttToGpio::Gpio::INPUT)
      expect(stubbed_gpio_pin).to have_received(:value).at_least(:once)
    end

    it "publishes a message when a pin value changes" do
      pin = 1
      name = "input1"
      hold = 200
      publisher = instance_double(MqttToGpio::Publisher)
      stubbed_gpio_pin = instance_double(MqttToGpio::Gpio::Pin, value: MqttToGpio::Gpio::LOW)
      allow(MqttToGpio::Gpio).to receive(:pin).and_yield(stubbed_gpio_pin)
      allow(publisher).to receive(:publish_state)

      watcher = MqttToGpio::Watcher.new(pin: pin, name: name, hold: hold, publisher: publisher)
      poller = nil
      allow(watcher).to(receive(:repeat)) { |_interval, &block| poller = block }
      watcher.run!

      allow(stubbed_gpio_pin).to receive(:value).and_return(MqttToGpio::Gpio::HIGH)
      poller.call

      expect(publisher).to have_received(:publish_state).with(name, MqttToGpio::Gpio::HIGH)
    end

    it "does not publish a message when a pin value does not change" do
      pin = 1
      name = "input1"
      hold = 200
      publisher = instance_double(MqttToGpio::Publisher)
      stubbed_gpio_pin = instance_double(MqttToGpio::Gpio::Pin, value: MqttToGpio::Gpio::LOW)
      allow(MqttToGpio::Gpio).to receive(:pin).and_yield(stubbed_gpio_pin)
      allow(publisher).to receive(:publish_state)

      watcher = MqttToGpio::Watcher.new(pin: pin, name: name, hold: hold, publisher: publisher)
      poller = nil
      allow(watcher).to(receive(:repeat)) { |_interval, &block| poller = block }
      watcher.run!

      poller.call

      expect(publisher).not_to have_received(:publish_state)
    end

    it "publishes a message when a pin is held" do
      pin = 1
      name = "input1"
      hold = 10
      publisher = instance_double(MqttToGpio::Publisher)
      stubbed_gpio_pin = instance_double(MqttToGpio::Gpio::Pin, value: MqttToGpio::Gpio::HIGH)
      allow(MqttToGpio::Gpio).to receive(:pin).and_yield(stubbed_gpio_pin)
      allow(publisher).to receive(:publish_hold)

      watcher = MqttToGpio::Watcher.new(pin: pin, name: name, hold: hold, publisher: publisher)
      poller = nil
      allow(watcher).to(receive(:repeat)) { |_interval, &block| poller = block }
      watcher.run!

      poller.call

      expect(publisher).to have_received(:publish_hold).with(name, 1)
    end
  end
end
