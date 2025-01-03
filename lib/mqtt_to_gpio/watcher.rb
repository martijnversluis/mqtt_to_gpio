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
        MqttToGpio.logger.debug "Starting watcher for #{name} (pin #{pin}), initial value: #{previous_value}"

        repeat(polling_interval_in_seconds) do
          poll_pin(gpio_pin)
        end
      end
    end

    private

    attr_reader :pin,
                :name,
                :hold,
                :publisher,
                :previous_value,
                :current_value

    def repeat(polling_interval_in_seconds, &block)
      loop do
        sleep(polling_interval_in_seconds)
        block.call
      end
    end

    def polling_interval_in_seconds
      POLLING_INTERVAL_IN_MS / 1000.0
    end

    def poll_pin(gpio_pin)
      @previous_value = @current_value if @current_value
      @current_value = gpio_pin.value

      if value_changed?
        handle_value_changed
      elsif hold? && pin_high?
        handle_pin_held
      end
    end

    def handle_value_changed
      MqttToGpio.logger.debug "Value changed for #{name} (pin #{pin}) from #{previous_value} to #{current_value}"
      @hold_count = 0 if pin_low?
      publisher.publish_state(name, current_value)
    end

    def handle_pin_held
      @hold_count += 1

      return unless (@hold_count % hold_interval).zero?

      hold_index = @hold_count / hold_interval
      MqttToGpio.logger.debug "Value held for #{name} (pin #{pin}) " \
                              "at #{current_value} for #{hold_index} intervals"
      publisher.publish_hold(name, hold_index)
    end

    def value_changed?
      previous_value != current_value
    end

    def pin_high?
      current_value == Gpio::HIGH
    end

    def pin_low?
      current_value == Gpio::LOW
    end

    def hold?
      hold && !hold.zero?
    end

    def hold_interval
      return unless hold?

      (hold.to_f / POLLING_INTERVAL_IN_MS).to_i
    end
  end
end
