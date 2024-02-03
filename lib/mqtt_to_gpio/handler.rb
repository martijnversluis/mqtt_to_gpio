# frozen_string_literal: true

module MqttToGpio
  class Handler
    def initialize(outputs)
      @outputs = outputs
    end

    def handle_message(device_id, desired_state)
      output = outputs.detect { |o| o.name == device_id }

      return if output.nil?

      Gpio.pin(output.pin, Gpio::OUTPUT) do |pin|
        pin.value = desired_state
      end
    end

    private

    attr_reader :outputs
  end
end
