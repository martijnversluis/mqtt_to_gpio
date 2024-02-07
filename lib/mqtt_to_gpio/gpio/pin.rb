# frozen_string_literal: true

module MqttToGpio
  module Gpio
    class Pin
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def export
        MqttToGpio.logger.debug "Exporting pin #{number}"
        File.write(Gpio.export_path, number)
        MqttToGpio.logger.debug "Exporting pin #{number} succeeded"
      rescue Errno::EBUSY
        MqttToGpio.logger.warn "Exporting pin #{number} failed: pin already exported"
        # Already exported
      end

      def unexport
        MqttToGpio.logger.debug "Unexporting pin #{number}"
        File.write(Gpio.unexport_path, number)
        MqttToGpio.logger.debug "Unexporting pin #{number} succeeded"
      end

      def direction
        MqttToGpio.logger.debug "Reading direction of pin #{number}"

        File.read(direction_path).strip.tap do |direction|
          MqttToGpio.logger.debug "Reading direction of pin #{number} succeeded: #{direction}"
        end
      end

      def direction=(value)
        MqttToGpio.logger.debug "Setting direction of pin #{number} to #{value}"
        File.write(direction_path, value)
        MqttToGpio.logger.debug "Setting direction of pin #{number} to #{value} succeeded"
      end

      def input?
        direction == Gpio::INPUT
      end

      def output?
        direction == Gpio::OUTPUT
      end

      def input!
        self.direction = Gpio::INPUT
      end

      def output!
        self.direction = Gpio::OUTPUT
      end

      def value
        File.read(value_path).strip
      end

      def value=(value)
        MqttToGpio.logger.debug "Setting value of pin #{number} to #{value}"
        File.write(value_path, value)
        MqttToGpio.logger.debug "Setting value of pin #{number} to #{value} succeeded"
      end

      def high?
        value == Gpio::HIGH
      end

      def low?
        value == Gpio::LOW
      end

      def high!
        self.value = Gpio::HIGH
      end

      def low!
        self.value = Gpio::LOW
      end

      private

      def value_path
        path("value")
      end

      def direction_path
        path("direction")
      end

      def path(filename)
        File.join(Gpio::BASE_PATH, "gpio#{number}", filename)
      end
    end
  end
end
