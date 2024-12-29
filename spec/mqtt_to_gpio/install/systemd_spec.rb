# frozen_string_literal: true

RSpec.describe MqttToGpio::Install::Systemd do
  describe "#run!" do
    it "writes the systemd service file" do
      installer = MqttToGpio::Install::Systemd.new
      allow(File).to receive(:write)
      allow(Dir).to receive(:pwd).and_return("/path/to/user")
      allow(installer).to receive(:system!)
      allow(installer).to receive(:system).and_return(true)

      allow(installer).to receive(:`) do |command|
        case command
        when "which mqtt_to_gpio"
          "/usr/local/bin/mqtt_to_gpio"
        when "whoami"
          "pi"
        end
      end

      installer.run!

      expect(File).to have_received(:write).with("/etc/systemd/system/mqtt_to_gpio.service", <<~SERVICE)
        [Unit]
        Description=MQTT to GPIO
        After=network.target

        [Service]
        Type=simple
        User=pi
        WorkingDirectory=/path/to/user
        ExecStart=/usr/local/bin/mqtt_to_gpio /path/to/user/mqtt_to_gpio.yml
        Restart=on-failure

        [Install]
        WantedBy=multi-user.target
      SERVICE
    end
  end
end
