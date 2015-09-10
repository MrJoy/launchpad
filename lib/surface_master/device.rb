module SurfaceMaster
  # Base class for MIDI controller drivers.
  #
  # Sub-classes should extend the constructor, extend `sysex_prefix`, implement `reset!`, and add
  # whatever methods are appropriate for them.
  class Device
    include Logging

    def initialize(opts = nil)
      opts        = { input: true, output: true }.merge(opts || {})
      self.logger = opts[:logger]
      @mutex      = Mutex.new
      @input      = create_input_device(opts)
      @output     = create_output_device(opts)
    end

    # Closes the device - nothing can be done with the device afterwards.
    def close
      logger.debug "Closing #{self.class}##{object_id}"
      @mutex.synchronize do
        @input.close unless @input.nil?
        @input = nil
        @output.close unless @output.nil?
        @output = nil
      end
    end

    def closed?; !(input_enabled? || output_enabled?); end
    def input_enabled?; !@input.nil?; end
    def output_enabled?; !@output.nil?; end

    def reset!; end

    def read
      fail SurfaceMaster::NoInputAllowedError unless input_enabled?
      result = nil
      @mutex.synchronize do
        result = @input.gets.collect do |midi_message|
          (code, note, velocity) = midi_message[:data]
          { timestamp: midi_message[:timestamp],
            state:     (velocity == 127) ? :down : :up,
            velocity:  velocity,
            code:      code,
            note:      note }
        end
      end
      result
    end

  protected

    def sysex_prefix; [0xF0]; end
    def sysex_suffix; 0xF7; end
    def sysex_msg(*payload); (sysex_prefix + [payload, sysex_suffix]).flatten.compact; end

    def sysex!(*payload)
      fail NoOutputAllowedError unless output_enabled?
      msg = sysex_msg(payload)
      logger.debug { "#{msg.length}: 0x#{msg.map { |b| '%02X' % b }.join(' ')}" }
      @mutex.synchronize do
        @output.puts(msg)
      end
      nil
    end

    def create_input_device(opts); create_device(opts, :input, UniMIDI::Input); end
    def create_output_device(opts); create_device(opts, :output, UniMIDI::Output); end

    def create_device(opts, kind, device_class)
      return nil unless opts[kind]
      name_pat  = /#{Regexp.escape(opts[:device_name] || @name)}/
      device    = device_class.find { |dd| dd.name.match(name_pat) }
      fail SurfaceMaster::NoSuchDeviceError unless device
      device.open
      device
    end

    def message(status, data1, data2); [status, data1, data2]; end
  end
end
