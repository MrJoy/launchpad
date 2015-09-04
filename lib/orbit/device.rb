require 'portmidi'

module Orbit

  # This class is used to exchange data with the Numark Orbit.
  # It provides methods to light LEDs and to get information about button presses/releases.
  #
  # Example:
  #
  #   require 'orbit/device'
  #
  #   device = Orbit::Device.new
  #   device.change :grid, :x => 4, :y => 4, :red => :high, :green => :low
  class Device
    include ControlCenter::Logging

    # Initializes the launchpad device. When output capabilities are requested,
    # the launchpad will be reset.
    #
    # Optional options hash:
    #
    # [<tt>:input</tt>]             whether to use MIDI input for user interaction,
    #                               <tt>true/false</tt>, optional, defaults to +true+
    # [<tt>:output</tt>]            whether to use MIDI output for data display,
    #                               <tt>true/false</tt>, optional, defaults to +true+
    # [<tt>:input_device_id</tt>]   ID of the MIDI input device to use,
    #                               optional, <tt>:device_name</tt> will be used if omitted
    # [<tt>:output_device_id</tt>]  ID of the MIDI output device to use,
    #                               optional, <tt>:device_name</tt> will be used if omitted
    # [<tt>:device_name</tt>]       Name of the MIDI device to use,
    #                               optional, defaults to "Launchpad"
    # [<tt>:logger</tt>]            [Logger] to be used by this device instance, can be changed afterwards
    #
    # Errors raised:
    #
    # [Launchpad::NoSuchDeviceError] when device with ID or name specified does not exist
    # [Launchpad::DeviceBusyError] when device with ID or name specified is busy
    def initialize(opts = nil)
      opts = {
        :input        => true,
        :output       => true
      }.merge(opts || {})

      self.logger = opts[:logger]
      logger.debug "initializing Launchpad::Device##{object_id} with #{opts.inspect}"

      Portmidi.start

      @input = create_device!(Portmidi.input_devices, Portmidi::Input,
        id:   opts[:input_device_id],
        name: opts[:device_name]
      ) if opts[:input]
      @output = create_device!(Portmidi.output_devices, Portmidi::Output,
        id:   opts[:output_device_id],
        name: opts[:device_name]
      ) if opts[:output]

      # reset if output_enabled?
    end

    # Closes the device - nothing can be done with the device afterwards.
    def close
      logger.debug "closing Orbit::Device##{object_id}"
      @input.close unless @input.nil?
      @input = nil
      @output.close unless @output.nil?
      @output = nil
    end

    # Determines whether this device has been closed.
    def closed?
      !(input_enabled? || output_enabled?)
    end

    # Determines whether this device can be used to read input.
    def input_enabled?
      !@input.nil?
    end

    # Determines whether this device can be used to output data.
    def output_enabled?
      !@output.nil?
    end

    def reset
      # TODO: Implement me.
      # set_layout(0x00)
      # output(Status::CC, Status::NIL, Status::NIL)
    end

    # Lights all LEDs (for testing purposes).
    #
    # Parameters (see Launchpad for values):
    #
    # [+brightness+] brightness of both LEDs for all buttons
    #
    # Errors raised:
    #
    # [Launchpad::NoOutputAllowedError] when output is not enabled
    # def test_leds(brightness = :high)
    #   brightness = brightness(brightness)
    #   if brightness == 0
    #     reset
    #   else
    #     output(Status::CC, Status::NIL, Velocity::TEST_LEDS + brightness)
    #   end
    # end


    # def sysex_prefix
    #   @sysex_prefix ||= [ # SysEx Begin:
    #                       0xF0,
    #                       # Manufacturer/Device:
    #                       0x00,
    #                       0x20,
    #                       0x29,
    #                       0x02,
    #                       0x18 ]
    # end

    # def sysex_suffix; 0xF7; end

    # def sysex_msg(*payload)
    #   (sysex_prefix + [payload, sysex_suffix]).flatten
    # end

    # def decode_led(opts)
    #   case
    #   when opts[:cc]
    #     [:cc, TYPE_TO_NOTE[opts[:cc]]]
    #   when opts[:grid]
    #     if opts[:grid] == :all
    #       [:all, nil]
    #     else
    #       [:grid, (opts[:grid][1] * 10) + opts[:grid][0] + 11]
    #     end
    #   when opts[:column]
    #     [:column, opts[:column]]
    #   when opts[:row]
    #     [:row, opts[:row]]
    #   end
    # end

    # def color_payload(opts)
    #   type, led = decode_led(opts)
    #   case type
    #   when :cc, :grid
    #     command = 0x0B
    #     color   = [opts[:red] || 0x00, opts[:green] || 0x00, opts[:blue] || 0x00]
    #   when :column
    #     command = 0x0C
    #     color   = opts[:color] || 0x00
    #   when :row
    #     command = 0x0D
    #     color   = opts[:color] || 0x00
    #   when :all
    #     command = 0x0E
    #     color   = opts[:color] || 0x00
    #   end
    #   [command, { led: led, color: color }]
    # end

    def read_pending_actions
      Array(input).collect do |midi_message|
        (code, note, velocity) = midi_message[:message]
        {
          raw:        midi_message,
          timestamp:  midi_message[:timestamp],
          state:      (velocity != 0 ? :down : :up),
          velocity:   velocity,
          code:       code,
          note:       note,
        }
      end
    end

    private

    # Creates input/output devices.
    #
    # Parameters:
    #
    # [+devices+]     array of portmidi devices
    # [+device_type]  class to instantiate (<tt>Portmidi::Input/Portmidi::Output</tt>)
    #
    # Options hash:
    #
    # [<tt>:id</tt>]    id of the MIDI device to use
    # [<tt>:name</tt>]  name of the MIDI device to use,
    #                   only used when <tt>:id</tt> is not specified,
    #                   defaults to "Launchpad"
    #
    # Returns:
    #
    # newly created device
    #
    # Errors raised:
    #
    # [Launchpad::NoSuchDeviceError] when device with ID or name specified does not exist
    # [Launchpad::DeviceBusyError] when device with ID or name specified is busy
    def create_device!(devices, device_type, opts)
      logger.debug "creating #{device_type} with #{opts.inspect}, choosing from portmidi devices #{devices.inspect}"
      id = opts[:id]
      if id.nil?
        name = opts[:name] || "Numark ORBIT"
        device = devices.select {|dev| dev.name == name}.first
        id = device.device_id unless device.nil?
      end
      if id.nil?
        message = "MIDI device #{opts[:id] || opts[:name]} doesn't exist"
        logger.fatal message
        raise ControlCenter::NoSuchDeviceError.new(message)
      end
      device_type.new(id)
    rescue RuntimeError => e
      logger.fatal "error creating #{device_type}: #{e.inspect}"
      raise ControlCenter::DeviceBusyError.new(e)
    end

    # Reads input from the MIDI device.
    #
    # Returns:
    #
    # an array of hashes with:
    #
    # [<tt>:message</tt>]   an array of
    #                       MIDI status code,
    #                       MIDI data 1 (note),
    #                       MIDI data 2 (velocity)
    #                       and a fourth value
    # [<tt>:timestamp</tt>] integer indicating the time when the MIDI message was created
    #
    # Errors raised:
    #
    # [Launchpad::NoInputAllowedError] when output is not enabled
    def input
      if @input.nil?
        logger.error "trying to read from device that's not been initialized for input"
        raise NoInputAllowedError
      end
      @input.read(16)
    end

    # # Writes data to the MIDI device.
    # #
    # # Parameters:
    # #
    # # [+status+]  MIDI status code
    # # [+data1+]   MIDI data 1 (note)
    # # [+data2+]   MIDI data 2 (velocity)
    # #
    # # Errors raised:
    # #
    # # [Launchpad::NoOutputAllowedError] when output is not enabled
    # def output(status, data1, data2)
    #   output_messages([message(status, data1, data2)])
    # end

    # # Writes several messages to the MIDI device.
    # #
    # # Parameters:
    # #
    # # [+messages+]  an array of hashes (usually created with message) with:
    # #               [<tt>:message</tt>]   an array of
    # #                                     MIDI status code,
    # #                                     MIDI data 1 (note),
    # #                                     MIDI data 2 (velocity)
    # #               [<tt>:timestamp</tt>] integer indicating the time when the MIDI message was created
    # def output_messages(messages)
    #   if @output.nil?
    #     logger.error "trying to write to device that's not been initialized for output"
    #     raise ControlCenter::NoOutputAllowedError
    #   end
    #   logger.debug "writing messages to launchpad:\n  #{messages.join("\n  ")}" if logger.debug?
    #   @output.write(messages)
    #   nil
    # end

    # # Calculates the MIDI data 1 value (note) for a button.
    # #
    # # Parameters (see Launchpad for values):
    # #
    # # [+type+] type of the button
    # #
    # # Options hash:
    # #
    # # [<tt>:x</tt>]     x coordinate
    # # [<tt>:y</tt>]     y coordinate
    # #
    # # Returns:
    # #
    # # integer to be used for MIDI data 1
    # #
    # # Errors raised:
    # #
    # # [Launchpad::NoValidGridCoordinatesError] when coordinates aren't within the valid range
    # def note(type, opts)
    #   note = TYPE_TO_NOTE[type]
    #   if note.nil?
    #     x = (opts[:x] || -1).to_i
    #     y = (opts[:y] || -1).to_i
    #     if x < 0 || x > 7 || y < 0 || y > 7
    #       logger.error "wrong coordinates specified: x=#{x}, y=#{y}"
    #       raise NoValidGridCoordinatesError.new("you need to specify valid coordinates (x/y, 0-7, from top left), you specified: x=#{x}, y=#{y}")
    #     end
    #     note = y * 10 + x
    #   end
    #   note
    # end

    # Calculates the MIDI data 2 value (velocity) for given brightness and mode values.
    #
    # Options hash:
    #
    # [<tt>:red</tt>]   brightness of red LED
    # [<tt>:green</tt>] brightness of green LED
    # [<tt>:mode</tt>]  button mode, defaults to <tt>:normal</tt>, one of:
    #                   [<tt>:normal/tt>]     updates the LED for all circumstances (the new value will be written to both buffers)
    #                   [<tt>:flashing/tt>]   updates the LED for flashing (the new value will be written to buffer 0 while in buffer 1, the value will be :off, see )
    #                   [<tt>:buffering/tt>]  updates the LED for the current update_buffer only
    #
    # Returns:
    #
    # integer to be used for MIDI data 2
    #
    # Errors raised:
    #
    # [Launchpad::NoValidBrightnessError] when brightness values aren't within the valid range
    # def velocity(opts)
    #   if opts.is_a?(Hash)
    #     red = brightness(opts[:red] || 0)
    #     green = brightness(opts[:green] || 0)
    #     color = 16 * green + red
    #     flags = case opts[:mode]
    #             when :flashing  then  8
    #             when :buffering then  0
    #             else                  12
    #             end
    #     color + flags
    #   else
    #     opts.to_i + 12
    #   end
    # end

    # Calculates the integer brightness for given brightness values.
    #
    # Parameters (see Launchpad for values):
    #
    # [+brightness+] brightness
    #
    # Errors raised:
    #
    # [Launchpad::NoValidBrightnessError] when brightness values aren't within the valid range
    # def brightness(brightness)
    #   case brightness
    #   when 0, :off            then 0
    #   when 1, :low,     :lo   then 1
    #   when 2, :medium,  :med  then 2
    #   when 3, :high,    :hi   then 3
    #   else
    #     logger.error "wrong brightness specified: #{brightness}"
    #     raise NoValidBrightnessError.new("you need to specify the brightness as 0/1/2/3, :off/:low/:medium/:high or :off/:lo/:hi, you specified: #{brightness}")
    #   end
    # end

    # Creates a MIDI message.
    #
    # Parameters:
    #
    # [+status+]  MIDI status code
    # [+data1+]   MIDI data 1 (note)
    # [+data2+]   MIDI data 2 (velocity)
    #
    # Returns:
    #
    # an array with:
    #
    # [<tt>:message</tt>]   an array of
    #                       MIDI status code,
    #                       MIDI data 1 (note),
    #                       MIDI data 2 (velocity)
    # [<tt>:timestamp</tt>] integer indicating the time when the MIDI message was created, in this case 0
    def message(status, data1, data2)
      {:message => [status, data1, data2], :timestamp => 0}
    end
  end
end
