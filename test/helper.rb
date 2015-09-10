require "minitest/spec"
require "minitest/autorun"
require "minitest/reporters"

MiniTest::Reporters.use!

require "mocha/setup"

require "surface_master"

# Mock for tests
module UniMIDI
  # Mock for tests
  class Input
    attr_accessor :device_id
    def initialize(device_id)
      self.device_id = device_id
    end

    def gets(*_args); nil; end
    def close; nil; end
  end

  # Mock for tests
  class Output
    attr_accessor :device_id
    def initialize(device_id)
      self.device_id = device_id
    end

    def puts(*_args); nil; end
    def close; nil; end
  end

  def self.input_devices; mock_devices; end
  def self.output_devices; mock_devices; end
  def self.start; end
end

def mock_devices(opts = {})
  [UniMIDI::Input.new(opts[:id] || 1, 0, 0, opts[:name] || "Launchpad MK2")]
end
