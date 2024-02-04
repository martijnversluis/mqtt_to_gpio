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

    class Listener
      def initialize(host:, port:, topic:, username:, password:)
        @host = host
        @port = port
        @topic = topic
        @username = username
        @password = password
      end

      def listen(&_block)
        connect(host: host, port: port, username: username, password: password) do |client|
          client.subscribe(topic)
          topic_regex = build_topic_regex(topic)
          wait_for_messages(client, topic_regex)
        end
      end

      private

      def wait_for_messages(client, topic_regex)
        client.get do |message_topic, payload|
          match = topic_regex.match(message_topic)

          if match
            device_id = match[1]
            yield(message_topic, device_id, payload)
          end
        end
      end

      attr_reader :host, :port, :topic, :username, :password

      def build_topic_regex(topic)
        topic
          .split("/")
          .map { |part| part == "#" ? "([^\\/]+)" : Regexp.escape(part) }
          .join(Regexp.escape("/"))
          .then { |str| Regexp.new("\\A#{str}\\z") }
      end
    end
  end
end
