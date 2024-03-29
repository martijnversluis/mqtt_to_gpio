# frozen_string_literal: true

module MqttToGpio
  module Gpio
    BASE_PATH = "/sys/class/gpio"
    EXPORT_PATH = File.join(BASE_PATH, "export")
    UNEXPORT_PATH = File.join(BASE_PATH, "unexport")
    INPUT = "in"
    OUTPUT = "out"
    HIGH = "1"
    LOW = "0"

    def pin(number, direction, &block)
      Pin
        .new(number)
        .tap(&:export)
        .tap { sleep 0.1 }
        .tap { |pin| pin.direction = direction }
        .tap(&block)
        .tap(&:unexport)
    end

    module_function :pin
  end
end
