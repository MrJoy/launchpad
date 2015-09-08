require "helper"

describe SurfaceMaster::Launchpad::Device do
  CONTROL_BUTTONS = { up:      0x68,
                      down:    0x69,
                      left:    0x6A,
                      right:   0x6B,
                      session: 0x6C,
                      user1:   0x6D,
                      user2:   0x6E,
                      mixer:   0x6F }
  SCENE_BUTTONS   = { scene1: 0x59,
                      scene2: 0x4F,
                      scene3: 0x45,
                      scene4: 0x3B,
                      scene5: 0x31,
                      scene6: 0x27,
                      scene7: 0x1D,
                      scene8: 0x13 }
  STATES          = { down: 127,
                      up:   0 }

  def expects_output(device, args)
    messages = args.map { |data| device.send(:sysex_prefix) + data + [device.send(:sysex_suffix)] }
    device.instance_variable_get("@output").expects(write_sysex: messages)
  end

  def stub_input(device, *args)
    device.instance_variable_get("@input").stubs(:read).returns(args)
  end

  describe '#initialize' do
    it "tries to initialize both input and output when not specified" do
      Portmidi.expects(:input_devices).returns(mock_devices)
      Portmidi.expects(:output_devices).returns(mock_devices)
      d = SurfaceMaster::Launchpad::Device.new
      refute_nil d.instance_variable_get("@input")
      refute_nil d.instance_variable_get("@output")
    end

    it "does not try to initialize input when set to false" do
      Portmidi.expects(:input_devices).never
      d = SurfaceMaster::Launchpad::Device.new(input: false)
      assert_nil d.instance_variable_get("@input")
      refute_nil d.instance_variable_get("@output")
    end

    it "does not try to initialize output when set to false" do
      Portmidi.expects(:output_devices).never
      d = SurfaceMaster::Launchpad::Device.new(output: false)
      refute_nil d.instance_variable_get("@input")
      assert_nil d.instance_variable_get("@output")
    end

    it "does not try to initialize any of both when set to false" do
      Portmidi.expects(:input_devices).never
      Portmidi.expects(:output_devices).never
      d = SurfaceMaster::Launchpad::Device.new(input: false, output: false)
      assert_nil d.instance_variable_get("@input")
      assert_nil d.instance_variable_get("@output")
    end

    it "initializes the correct input output devices when specified by name" do
      Portmidi.stubs(:input_devices).returns(mock_devices(id: 4, name: "Launchpad Name"))
      Portmidi.stubs(:output_devices).returns(mock_devices(id: 5, name: "Launchpad Name"))
      d = SurfaceMaster::Launchpad::Device.new(device_name: "Launchpad Name")
      assert_equal Portmidi::Input, (input = d.instance_variable_get("@input")).class
      assert_equal 4, input.device_id
      assert_equal Portmidi::Output, (output = d.instance_variable_get("@output")).class
      assert_equal 5, output.device_id
    end

    it "initializes the correct input output devices when specified by id" do
      Portmidi.stubs(:input_devices).returns(mock_devices(id: 4))
      Portmidi.stubs(:output_devices).returns(mock_devices(id: 5))
      d = SurfaceMaster::Launchpad::Device.new(input_device_id:   4,
                                               output_device_id:  5,
                                               device_name:       "nonexistant")
      assert_equal Portmidi::Input, (input = d.instance_variable_get("@input")).class
      assert_equal 4, input.device_id
      assert_equal Portmidi::Output, (output = d.instance_variable_get("@output")).class
      assert_equal 5, output.device_id
    end

    it "raises NoSuchDeviceError when requested input device does not exist" do
      assert_raises SurfaceMaster::NoSuchDeviceError do
        Portmidi.stubs(:input_devices).returns(mock_devices(name: "Launchpad Input"))
        SurfaceMaster::Launchpad::Device.new
      end
    end

    it "raises NoSuchDeviceError when requested output device does not exist" do
      assert_raises SurfaceMaster::NoSuchDeviceError do
        Portmidi.stubs(:output_devices).returns(mock_devices(name: "Launchpad Output"))
        SurfaceMaster::Launchpad::Device.new
      end
    end

    it "raises DeviceBusyError when requested input device is busy" do
      assert_raises SurfaceMaster::DeviceBusyError do
        Portmidi::Input.stubs(:new).raises(RuntimeError)
        SurfaceMaster::Launchpad::Device.new
      end
    end

    it "raises DeviceBusyError when requested output device is busy" do
      assert_raises SurfaceMaster::DeviceBusyError do
        Portmidi::Output.stubs(:new).raises(RuntimeError)
        SurfaceMaster::Launchpad::Device.new
      end
    end

    it "stores the logger given" do
      logger = Logger.new(nil)
      device = SurfaceMaster::Launchpad::Device.new(logger: logger)
      assert_same logger, device.logger
    end
  end

  describe '#close' do
    it "does not fail when neither input nor output are there" do
      SurfaceMaster::Launchpad::Device.new(input: false, output: false).close
    end

    describe "with input and output devices" do
      before do
        Portmidi::Input.stubs(:new).returns(@input = mock("input"))
        Portmidi::Output.stubs(:new).returns(@output = mock("output"))
        @device = SurfaceMaster::Launchpad::Device.new
      end

      it "closes input/output and raise NoInputAllowedError/NoOutputAllowedError on subsequent read/write accesses" do
        @input.expects(:close)
        @output.expects(:close)
        @device.close
        assert_raises SurfaceMaster::NoInputAllowedError do
          @device.read
        end
        assert_raises SurfaceMaster::NoOutputAllowedError do
          @device.change(cc: :mixer, red: 0x00, green: 0x00, blue: 0x00)
        end
      end
    end
  end

  describe '#closed?' do
    it "returns true when neither input nor output are there" do
      assert SurfaceMaster::Launchpad::Device.new(input: false, output: false).closed?
    end

    it "returns false when initialized with input" do
      assert !SurfaceMaster::Launchpad::Device.new(input: true, output: false).closed?
    end

    it "returns false when initialized with output" do
      assert !SurfaceMaster::Launchpad::Device.new(input: false, output: true).closed?
    end

    it "returns false when initialized with both but true after calling close" do
      d = SurfaceMaster::Launchpad::Device.new
      assert !d.closed?
      d.close
      assert d.closed?
    end
  end

  { reset: [[0x22, 0x00],
            [0xB0, 0x00, 0x00]],
    # flashing_on:    [0xB0, 0x00, 0x20],
    # flashing_off:   [0xB0, 0x00, 0x21],
    # flashing_auto:  [0xB0, 0x00, 0x28],
  }.each do |method, codes|
    describe "##{method}" do
      it "raises NoOutputAllowedError when not initialized with output" do
        assert_raises SurfaceMaster::NoOutputAllowedError do
          SurfaceMaster::Launchpad::Device.new(output: false).send(method)
        end
      end

      it "sends #{codes.inspect}" do
        d = SurfaceMaster::Launchpad::Device.new
        expects_output(d, codes)
        d.send(method)
      end
    end
  end

  describe '#change' do
    it "raises NoOutputAllowedError when not initialized with output" do
      assert_raises SurfaceMaster::NoOutputAllowedError do
        SurfaceMaster::Launchpad::Device.new(output: false)
          .change(cc: :mixer, red: 0x00, green: 0x00, blue: 0x00)
      end
    end

    describe "initialized with output" do
      before do
        @device = SurfaceMaster::Launchpad::Device.new(input: false)
      end

      it "returns nil" do
        assert_nil @device.change(cc: :mixer, red: 0x00, green: 0x00, blue: 0x00)
      end

      describe "control buttons" do
        CONTROL_BUTTONS.each do |type, value|
          input   = { cc: type, red: 0x01, green: 0x02, blue: 0x03 }
          output  = [0x0B, value, 0x01, 0x02, 0x03]
          it "sends #{output.inspect} when given #{input.inspect}" do
            expects_output(@device, [output])
            @device.change(input)
          end
        end
      end

      describe "scene buttons" do
        SCENE_BUTTONS.each do |type, value|
          input   = { cc: type, red: 0x01, green: 0x02, blue: 0x03 }
          output  = [0x0B, value, 0x01, 0x02, 0x03]
          it "sends #{output.inspect} when given #{input.inspect}" do
            expects_output(@device, [output])
            @device.change(input)
          end
        end
      end

      describe "grid buttons" do
        8.times do |x|
          8.times do |y|
            input   = { grid: [x, y], red: 0x01, green: 0x02, blue: 0x03 }
            output  = [0x0B, 10 * y + x + 11, 0x01, 0x02, 0x03]

            it "sends #{output.inspect} when given #{input.inspect}" do
              expects_output(@device, [output])
              @device.change(input)
            end
          end
        end

        it "raises NoValidGridCoordinatesError if x is nil" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [nil, 1], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if it only gets one coordinate" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [1], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if x is below 0" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [-1, 1], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if x is above 7" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [8, 1], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if y is nil" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [1, nil], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if y is below 0" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [1, -1], red: 0x01, green: 0x02, blue: 0x03)
          end
        end

        it "raises NoValidGridCoordinatesError if y is above 7" do
          assert_raises SurfaceMaster::Launchpad::NoValidGridCoordinatesError do
            @device.change(grid: [1, 8], red: 0x01, green: 0x02, blue: 0x03)
          end
        end
      end
    end
  end

  describe '#read' do
    it "raises NoInputAllowedError when not initialized with input" do
      assert_raises SurfaceMaster::NoInputAllowedError do
        SurfaceMaster::Launchpad::Device.new(input: false).read
      end
    end

    describe "initialized with input" do
      before do
        @device = SurfaceMaster::Launchpad::Device.new(output: false)
      end

      describe "control buttons" do
        CONTROL_BUTTONS.each do |type, value|
          STATES.each do |state, velocity|
            it "builds proper action for control button #{type}, #{state}" do
              stub_input(@device, timestamp: 0, message: [0xB0, value, velocity])
              assert_equal [{ timestamp: 0, state: state, type: type }], @device.read
            end
          end
        end
      end

      describe "scene buttons" do
        SCENE_BUTTONS.each do |type, value|
          STATES.each do |state, velocity|
            it "builds proper action for scene button #{type}, #{state}" do
              stub_input(@device, timestamp: 0, message: [0x90, value, velocity])
              assert_equal [{ timestamp: 0, state: state, type: type }], @device.read
            end
          end
        end
      end

      describe '#grid buttons' do
        8.times do |x|
          8.times do |y|
            STATES.each do |state, velocity|
              it "builds proper action for grid button #{x},#{y}, #{state}" do
                stub_input(@device, timestamp: 0, message: [0x90, 10 * y + x + 11, velocity])
                assert_equal [{ timestamp: 0, state: state, type: :grid, x: x, y: y }], @device.read
              end
            end
          end
        end
      end

      it "builds proper actions for multiple pending actions" do
        TEST_MESSAGES   = [{ timestamp: 1, message: [0x90, 0x0B, 0x7F] },
                           { timestamp: 2, message: [0xB0, 0x68, 0x00] }]
        TEST_OUTPUTS    = [{ timestamp: 1, state: :down,  type: :grid, x: 0, y: 0 },
                           { timestamp: 2, state: :up,    type: :up }]
        stub_input(@device, *TEST_MESSAGES)
        assert_equal TEST_OUTPUTS, @device.read
      end
    end
  end
end
