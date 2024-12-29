# frozen_string_literal: true

require "mqtt"

module MqttToGpio
  class Mqtt
    class << self
      def publish(host:, port:, username:, password:, topic:, payload:)
        connect(host: host, port: port, username: username, password: password) do |client|
          client.publish(topic, payload)
        end
      end

      def connect(host:, port:, username:, password:, &block)
        using_password = !(password.nil? || password.empty?)
        logged_password = using_password ? "<REDACTED>" : "<NONE>"

        MqttToGpio.logger.debug <<~MESSAGE
          Connecting to MQTT broker at #{host}:#{port} using username #{username} and password #{logged_password}
        MESSAGE

        ::MQTT::Client.connect(host: host, port: port, username: username, password: password, &block)
      end

      def listen(host:, port:, username:, password:, topic:, &block)
        Listener
          .new(host: host, port: port, username: username, password: password, topic: topic)
          .listen(&block)
      end
    end
  end
end
