# frozen_string_literal: true

require "parallel"

module MqttToGpio
  class Server
    def initialize(configuration)
      @configuration = configuration
    end

    def run!
      Parallel.each([*watchers, listener].compact, &:run!)
    end

    private

    attr_reader :configuration

    def watchers
      configuration.fetch("inputs", []).map do |input|
        Watcher.new(
          pin: input.fetch("pin"),
          name: input.fetch("name"),
          hold: input.fetch("hold", false),
          publisher: publisher
        )
      end
    end

    def listener
      outputs = configuration.fetch("outputs", [])

      return if outputs.empty?

      Listener.new(
        host: mqtt_config.fetch("host"),
        port: mqtt_config.fetch("port", nil),
        username: mqtt_config.fetch("username", nil),
        password: mqtt_config.fetch("password", nil),
        topic_prefix: mqtt_config.fetch("topic_prefix"),
        handler: handler
      )
    end

    def handler
      @handler ||= Handler.new(outputs)
    end

    def publisher
      @publisher ||= Publisher.new(
        host: mqtt_config.fetch("host"),
        port: mqtt_config.fetch("port", nil),
        username: mqtt_config.fetch("username", nil),
        password: mqtt_config.fetch("password", nil),
        topic_prefix: mqtt_config.fetch("topic_prefix")
      )
    end

    def mqtt_config
      configuration.fetch("mqtt")
    end
  end
end
