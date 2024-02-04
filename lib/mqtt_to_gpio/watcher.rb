# frozen_string_literal: true

module MqttToGpio
  class Watcher
    POLLING_INTERVAL_IN_MS = 10

    def initialize(pin:, name:, hold:, publisher:)
      @pin = pin
      @name = name
      @hold = hold
      @publisher = publisher
      @last_value = nil
      @hold_count = 0
    end

    def run!
      Gpio.pin(pin, Gpio::INPUT) do |pin|
        @last_state = pin.value

        loop do
          sleep(polling_interval_in_seconds)
          poll_pin(pin)
        end
      end
    end

    private

    def polling_interval_in_seconds
      POLLING_INTERVAL_IN_MS / 1000.0
    end

    def poll_pin(pin)
      current_value = pin.value
      value_changed = current_value != last_value

      if value_changed
        @hold_count = 0 if current_value == Gpio::OFF
        publisher.publish_state(name, current_value)
      elsif hold? && current_value == Gpio::ON
        @hold_count += 1
        publisher.publish_hold(name, @hold_count) if (@hold_count % hold_interval).zero?
      end
    end

    attr_reader :pin, :name, :hold, :publisher

    def hold?
      !hold.nil? && !hold.zero?
    end

    def hold_interval
      return unless hold?

      (hold.to_f / POLLING_INTERVAL_IN_MS).to_i
    end
  end
end
