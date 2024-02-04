# frozen_string_literal: true

module MqttToGpio
  class Listener
    def initialize(host:, port:, username:, password:, topic_prefix:, handler:)
      @host = host
      @port = port
      @username = username
      @password = password
      @topic_prefix = topic_prefix
      @handler = handler
    end

    def run!
      Mqtt::Listener.new(
        host: host,
        port: port,
        username: username,
        password: password,
        topic: "#{topic_prefix}/output/#/set"
      ).listen do |_topic, device_id, message|
        logger.debug "Received MQTT message for #{device_id} with desired state #{message}"
        handler.handle_message(device_id, message)
      end
    end

    private

    attr_reader :host, :port, :username, :password, :topic_prefix, :handler
  end
end
