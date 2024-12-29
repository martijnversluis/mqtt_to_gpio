# frozen_string_literal: true

RSpec.describe MqttToGpio::Gpio::Pin do
  around(:example) do |example|
    Dir.mktmpdir do |dir|
      example.metadata[:temp_dir] = dir
      FileUtils.touch("#{dir}/export")
      FileUtils.touch("#{dir}/unexport")
      example.run
    end
  end

  describe "#export" do
    it "exports the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.export

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/export")).to eq "17"
    end
  end

  describe "#unexport" do
    it "unexports the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.unexport

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/unexport")).to eq "17"
    end
  end

  describe "#direction" do
    it "returns the direction of the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "in")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin.direction).to eq "in"
    end
  end

  describe "#direction=" do
    it "sets the direction of the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "out")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.direction = "in"

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/direction")).to eq "in"
    end
  end

  describe "#input?" do
    it "returns true if the direction is in" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "in")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).to be_input
    end

    it "returns false if the direction is out" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "out")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).not_to be_input
    end
  end

  describe "#output?" do
    it "returns true if the direction is out" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "out")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).to be_output
    end

    it "returns false if the direction is in" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/direction", "in")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).not_to be_output
    end
  end

  describe "#output!" do
    it "sets the direction of the pin to out" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)
      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      FileUtils.touch("#{temp_dir}/gpio17/direction")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.output!

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/direction")).to eq "out"
    end
  end

  describe "#input!" do
    it "sets the direction of the pin to in" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)
      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      FileUtils.touch("#{temp_dir}/gpio17/direction")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.input!

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/direction")).to eq "in"
    end
  end

  describe "#value" do
    it "returns the value of the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "1")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin.value).to eq "1"
    end
  end

  describe "#value=" do
    it "sets the value of the pin" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "0")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.value = "1"

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/value")).to eq "1"
    end
  end

  describe "#high?" do
    it "returns true if the value is high" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "1")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).to be_high
    end

    it "returns false if the value is low" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "0")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).not_to be_high
    end
  end

  describe "#low?" do
    it "returns true if the value is low" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "0")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).to be_low
    end

    it "returns false if the value is high" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)

      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "0")

      pin = MqttToGpio::Gpio::Pin.new(17)

      expect(pin).not_to be_high
    end
  end

  describe "#high!" do
    it "sets the value of the pin to high" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)
      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "0")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.high!

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/value")).to eq "1"
    end
  end

  describe "#low!" do
    it "sets the value of the pin to low" do |example|
      temp_dir = example.metadata[:temp_dir]
      stub_const("MqttToGpio::Gpio::BASE_PATH", temp_dir)
      FileUtils.mkdir_p("#{temp_dir}/gpio17")
      File.write("#{temp_dir}/gpio17/value", "1")

      pin = MqttToGpio::Gpio::Pin.new(17)
      pin.low!

      expect(File.read("#{MqttToGpio::Gpio::BASE_PATH}/gpio17/value")).to eq "0"
    end
  end
end
