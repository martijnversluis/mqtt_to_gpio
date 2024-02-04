# frozen_string_literal: true

module MqttToGpio
  module Gpio
    class Pin
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def export
        with_retry(Errno::EBUSY) do
          File.write(Gpio::EXPORT_PATH, number)
        end
      end

      def unexport
        with_retry(Errno::EBUSY) do
          File.write(Gpio::UNEXPORT_PATH, number)
        end
      end

      def direction
        File.read(direction_path).strip
      end

      def direction=(value)
        File.write(direction_path, value)
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
        File.write(value_path, value)
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
