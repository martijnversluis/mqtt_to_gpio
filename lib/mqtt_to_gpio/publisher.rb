# frozen_string_literal: true

require "json"

module MqttToGpio
  class Publisher
    HOLD = "HOLD"

    def initialize(host:, port:, username:, password:, topic_prefix:)
      @host = host
      @port = port
      @username = username
      @password = password
      @topic_prefix = topic_prefix
    end

    def publish_state(device_id, state)
      publish(device_id, { state: state })
    end

    def publish_hold(device_id, hold_count)
      publish(device_id, { state: HOLD, hold_count: hold_count })
    end

    private

    attr_reader :host, :port, :username, :password, :topic_prefix

    def publish(device_id, state)
      MqttToGpio.logger.debug("Publishing state #{state} for #{device_id}")

      Mqtt.publish(
        host: host,
        port: port,
        username: username,
        password: password,
        topic: "#{topic_prefix}/input/#{device_id}",
        payload: state.to_json
      )
    end
  end
end
