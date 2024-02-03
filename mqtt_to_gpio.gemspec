# frozen_string_literal: true

require_relative "lib/mqtt_to_gpio/version"

Gem::Specification.new do |spec|
  spec.name = "mqtt_to_gpio"
  spec.version = MqttToGpio::VERSION
  spec.authors = ["Martijn Versluis"]
  spec.email = ["martijnversluis@users.noreply.github.com"]

  spec.summary = "Expose Raspberry Pi GPIO pins to MQTT."
  spec.homepage = "https://github.com/martijnversluis/mqtt_to_gpio"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "bin"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "mqtt", "~> 0.6"
  spec.add_dependency "parallel", "~> 1.23"
end
