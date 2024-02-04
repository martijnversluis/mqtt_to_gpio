# frozen_string_literal: true

module MqttToGpio
  class Watcher
    POLLING_INTERVAL_IN_MS = 10

    def initialize(pin:, name:, hold:, publisher:)
      @pin = pin
      @name = name
      @hold = hold
      @publisher = publisher
      @previous_value = nil
      @current_value = nil
      @hold_count = 0
    end

    def run!
      Gpio.pin(pin, Gpio::INPUT) do |gpio_pin|
        @previous_value = gpio_pin.value
        MqttToGpio.logger.debug "Starting watcher for #{name} (pin #{gpio_pin}), initial value: #{previous_value}"

        loop do
          sleep(polling_interval_in_seconds)
          poll_pin(gpio_pin)
        end
      end
    end

    private

    def polling_interval_in_seconds
      POLLING_INTERVAL_IN_MS / 1000.0
    end

    def poll_pin(gpio_pin)
      @previous_value = @current_value if @current_value
      @current_value = gpio_pin.value

      if value_changed?
        handle_value_changed
      elsif hold? && pin_on?
        handle_pin_held
      end
    end

    def handle_pin_held
      @hold_count += 1
      MqttToGpio.logger.debug "Value held for #{name} (pin #{pin}) at #{current_value} for #{@hold_count} intervals"
      publisher.publish_hold(name, @hold_count) if (@hold_count % hold_interval).zero?
    end

    def handle_value_changed
      MqttToGpio.logger.debug "Value changed for #{name} (pin #{pin}) from #{previous_value} to #{current_value}"
      @hold_count = 0 if pin_off?
      publisher.publish_state(name, current_value)
    end

    attr_reader :pin, :name, :hold, :publisher, :previous_value, :current_value

    def value_changed?
      previous_value != current_value
    end

    def pin_on?
      current_value == Gpio::ON
    end

    def pin_off?
      current_value == Gpio::OFF
    end

    def hold?
      !hold.nil? && !hold.zero?
    end

    def hold_interval
      return unless hold?

      (hold.to_f / POLLING_INTERVAL_IN_MS).to_i
    end
  end
end
