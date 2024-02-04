# frozen_string_literal: true

module MqttToGpio
  class Handler
    def initialize(outputs)
      @outputs = outputs
    end

    def handle_message(device_id, desired_state)
      MqttToGpio.logger.debug("Handler received message for #{device_id} with desired state #{desired_state}")
      output = outputs.detect { |o| o.fetch("name") == device_id }

      if output.nil?
        MqttToGpio.logger.warn("Received message for unknown device: #{device_id}")
        return
      end

      pin = output.fetch("pin")
      MqttToGpio.logger.info("Setting #{device_id} (pin #{pin}) to #{desired_state}")
      Gpio.pin(pin, Gpio::OUTPUT) { |pin| pin.value = desired_state }
      MqttToGpio.logger.info("Setting #{device_id} (pin #{pin}) to #{desired_state} succeeded")
    end

    private

    attr_reader :outputs
  end
end
