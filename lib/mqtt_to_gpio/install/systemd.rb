# frozen_string_literal: true

module MqttToGpio
  module Install
    class Systemd
      def run!
        File.write("/etc/systemd/system/mqtt_to_gpio.service", systemd_service_file)
        system! "sudo systemctl daemon-reload"
        system! "systemctl enable mqtt_to_gpio"
        system! "systemctl start mqtt_to_gpio"
      end

      private

      def system!(*args)
        system(*args) || abort("\n== Command #{args} failed ==")
      end

      def systemd_service_file
        <<~SERVICE
          [Unit]
          Description=MQTT to GPIO
          After=network.target

          [Service]
          Type=simple
          User=#{`whoami`.strip}
          WorkingDirectory=#{Dir.pwd}
          ExecStart=#{`which mqtt_to_gpio`.strip} #{Dir.pwd}/mqtt_to_gpio.yml
          Restart=on-failure

          [Install]
          WantedBy=multi-user.target
        SERVICE
      end
    end
  end
end
