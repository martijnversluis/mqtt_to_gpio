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
          User=pi
          WorkingDirectory=#{Dir.pwd}
          ExecStart=#{Gem.ruby} -I#{Dir.pwd}/lib #{Dir.pwd}/bin/mqtt_to_gpio #{Dir.pwd}/mqtt_to_gpio.yml
          Restart=on-failure

          [Install]
          WantedBy=multi-user.target
        SERVICE
      end
    end
  end
end
