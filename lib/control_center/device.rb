module ControlCenter
  # Base class for MIDI controller drivers.
  #
  # Sub-classes should extend the constructor, extend `sysex_prefix`, implement `reset!`, and add
  # whatever methods are appropriate for them.
  class Device
    include Logging

    def initialize(opts = nil)
      opts  = { input:  true,
                output: true }
              .merge(opts || {})

      self.logger = opts[:logger]
      logger.debug "Initializing #{self.class}##{object_id} with #{opts.inspect}"

      @input    = create_device!(Portmidi.input_devices,
                                 Portmidi::Input,
                                 id:   opts[:input_device_id],
                                 name: opts[:device_name]) if opts[:input]
      @output   = create_device!(Portmidi.output_devices,
                                 Portmidi::Output,
                                 id:   opts[:output_device_id],
                                 name: opts[:device_name]) if opts[:output]
    end

    # Closes the device - nothing can be done with the device afterwards.
    def close
      logger.debug "Closing #{self.class}##{object_id}"
      @input.close unless @input.nil?
      @input = nil
      @output.close unless @output.nil?
      @output = nil
    end

    def closed?; !(input_enabled? || output_enabled?); end
    def input_enabled?; !@input.nil?; end
    def output_enabled?; !@output.nil?; end

    def reset!; end

    def read
      unless input_enabled?
        logger.error "Trying to read from device that's not been initialized for input!"
        raise ControlCenter::NoInputAllowedError
      end

      Array(@input.read(16)).collect do |midi_message|
        (code, note, velocity) = midi_message[:message]
        { timestamp:  midi_message[:timestamp],
          state:      (velocity == 127) ? :down : :up,
          velocity:   velocity,
          code:       code,
          note:       note }
      end
    end

  protected

    def sysex_prefix; [0xF0]; end
    def sysex_suffix; 0xF7; end
    def sysex_msg(*payload); (sysex_prefix + [payload, sysex_suffix]).flatten.compact; end
    def sysex!(*payload)
      msg = sysex_msg(payload)
      puts "#{msg.length}: 0x#{msg.map(&:to_hex).join(", 0x")}"
      @output.write_sysex(msg)
    end

    def create_device!(devices, device_type, opts)
      logger.debug "Creating #{device_type} with #{opts.inspect}, choosing from portmidi devices: #{devices.inspect}"
      id = opts[:id]
      if id.nil?
        name    = opts[:name] || @name
        device  = devices.select { |dev| dev.name == name }.first
        id      = device.device_id unless device.nil?
      end
      if id.nil?
        message = "MIDI Device `#{opts[:id] || opts[:name]}` doesn't exist!"
        logger.fatal message
        raise ControlCenter::NoSuchDeviceError.new(message)
      end
      device_type.new(id)
    rescue RuntimeError => e # TODO: Uh, this should be StandardException, perhaps?
      logger.fatal "Error creating #{device_type}: #{e.inspect}"
      raise ControlCenter::DeviceBusyError.new(e)
    end

    def message(status, data1, data2); { message: [status, data1, data2], timestamp: 0 }; end
  end
end
