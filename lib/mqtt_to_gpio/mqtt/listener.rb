# frozen_string_literal: true

module MqttToGpio
  class Mqtt
    class Listener
      def initialize(host:, port:, topic:, username:, password:)
        @host = host
        @port = port
        @topic = topic
        @username = username
        @password = password
      end

      def listen(&block)
        Mqtt.connect(host: host, port: port, username: username, password: password) do |client|
          MqttToGpio.logger.debug "Subscribing to topic #{topic}"
          client.subscribe(topic)
          topic_regex = build_topic_regex(topic)
          wait_for_messages(client, topic_regex, &block)
        end
      end

      private

      def wait_for_messages(client, topic_regex, &block)
        MqttToGpio.logger.debug "Waiting for messages on topic #{topic_regex}"

        client.get do |message_topic, payload|
          match = topic_regex.match(message_topic)

          if match
            yield_matched_message(match, message_topic, payload, &block)
          else
            MqttToGpio.logger.debug "Received message on topic #{message_topic} " \
                                    "that does not match the expected pattern"
          end
        end
      end

      def yield_matched_message(match, message_topic, payload, &_block)
        device_id = match[1]
        MqttToGpio.logger.debug "Received message for device #{device_id} " \
                                "on topic #{message_topic} with payload #{payload}"
        yield(message_topic, device_id, payload)
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
