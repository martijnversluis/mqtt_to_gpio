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
        File.write(Gpio::EXPORT_PATH, number)
        MqttToGpio.logger.debug "Exporting pin #{number} succeeded"
      rescue Errno::EBUSY
        MqttToGpio.logger.warn "Exporting pin #{number} failed: pin already exported"
        # Already exported
      end

      def unexport
        MqttToGpio.logger.debug "Unexporting pin #{number}"
        File.write(Gpio::UNEXPORT_PATH, number)
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

      def on?
        value == Gpio::ON
      end

      def off?
        value == Gpio::OFF
      end

      def on!
        self.value = Gpio::ON
      end

      def off!
        self.value = Gpio::OFF
      end

      private

      def with_retry(rescued_exceptions, attempts: 5, wait: 0.1, &_block)
        attempts.times do
          yield
          return
        rescue *rescued_exceptions
          sleep wait
        end

        raise "Failed to perform operation after #{attempts} attempts"
      end

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
