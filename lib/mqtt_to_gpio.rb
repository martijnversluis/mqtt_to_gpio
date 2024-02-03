# frozen_string_literal: true

require "yaml"

module MqttToGpio
  def run!(config_file)
    config = YAML.load_file(config_file)
    Server.new(config).run!
  end

  module_function :run!
end

require_relative "mqtt_to_gpio/gpio"
require_relative "mqtt_to_gpio/gpio/pin"
require_relative "mqtt_to_gpio/handler"
require_relative "mqtt_to_gpio/listener"
require_relative "mqtt_to_gpio/mqtt"
require_relative "mqtt_to_gpio/publisher"
require_relative "mqtt_to_gpio/server"
require_relative "mqtt_to_gpio/version"
require_relative "mqtt_to_gpio/watcher"
