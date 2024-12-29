# frozen_string_literal: true

module MqttToGpio
  module Gpio
    BASE_PATH = "/sys/class/gpio"
    EXPORT_PATH_SUFFIX = "export"
    UNEXPORT_PATH_SUFFIX = "unexport"
    INPUT = "in"
    OUTPUT = "out"
    HIGH = "1"
    LOW = "0"

    module_function

    def pin(number, direction, &block)
      Pin
        .new(number)
        .tap(&:export)
        .tap { sleep 0.1 }
        .tap { |pin| pin.direction = direction }
        .tap(&block)
        .tap(&:unexport)
    end

    def export_path
      File.join(BASE_PATH, EXPORT_PATH_SUFFIX)
    end

    def unexport_path
      File.join(BASE_PATH, UNEXPORT_PATH_SUFFIX)
    end
  end
end
