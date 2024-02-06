# frozen_string_literal: true

require "logger"
require "yaml"

module MqttToGpio
  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout)
    end

    def install!
      Install::Systemd.new.run!
    end

    def run!(config_file)
      config = YAML.load_file(config_file)
      logger.debug "Starting server with configuration: #{config}"
      Server.new(config).run!
    end
  end
end

require_relative "mqtt_to_gpio/gpio"
require_relative "mqtt_to_gpio/gpio/pin"
require_relative "mqtt_to_gpio/handler"
require_relative "mqtt_to_gpio/install/systemd"
require_relative "mqtt_to_gpio/listener"
require_relative "mqtt_to_gpio/mqtt"
require_relative "mqtt_to_gpio/publisher"
require_relative "mqtt_to_gpio/server"
require_relative "mqtt_to_gpio/version"
require_relative "mqtt_to_gpio/watcher"
