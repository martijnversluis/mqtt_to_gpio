# frozen_string_literal: true

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

    def publish(device_id, state)
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
