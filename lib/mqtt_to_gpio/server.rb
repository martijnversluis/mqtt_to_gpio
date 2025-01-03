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
      configuration
        .fetch("inputs", [])
        .tap { |inputs| MqttToGpio.logger.debug "Initializing #{inputs.size} watchers" }
        .map(&method(:build_watcher))
    end

    def build_watcher(input)
      Watcher.new(
        pin: input.fetch("pin"),
        name: input.fetch("name"),
        hold: input.fetch("hold", false),
        publisher: publisher
      )
    end

    def listener
      if outputs.empty?
        MqttToGpio.logger.warn "No outputs configured, skipping listener"
        return
      end

      MqttToGpio.logger.debug "Initializing listener for #{outputs.size} outputs"
      Listener.new(**mqtt_config, handler: handler)
    end

    def handler
      @handler ||= Handler.new(outputs)
    end

    def outputs
      configuration.fetch("outputs", [])
    end

    def publisher
      @publisher ||= Publisher.new(**mqtt_config)
    end

    def mqtt_config
      configuration.fetch("mqtt").then do |config|
        {
          host: config.fetch("host"),
          port: config.fetch("port", nil),
          username: config.fetch("username", nil),
          password: config.fetch("password", nil),
          topic_prefix: config.fetch("topic_prefix")
        }
      end
    end
  end
end
