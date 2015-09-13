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
      # @mutex_i    = Mutex.new
      # @mutex_o    = Mutex.new
      @messages  = []
      @input      = create_input_device(opts)
      @output     = create_output_device(opts)
    end

    # Closes the device - nothing can be done with the device afterwards.
    def close
      logger.debug "Closing #{self.class}##{object_id}"
      # @mutex_i.synchronize do
        @input.close_port unless @input.nil?
        @input = nil
      # end
      # @mutex_o.synchronize do
        @output.close_port unless @output.nil?
        @output = nil
      # end
    end

    def closed?; !(input_enabled? || output_enabled?); end
    def input_enabled?; !@input.nil?; end
    def output_enabled?; !@output.nil?; end

    def reset!; end

    def read
      fail SurfaceMaster::NoInputAllowedError unless input_enabled?
      result = nil
      # @mutex_i.synchronize do
        tmp       = @messages
        @messages = []
        result    = tmp.collect do |midi_message|
          (code, note, velocity) = *midi_message
          { state:     (velocity == 127) ? :down : :up,
            velocity:  velocity,
            code:      code,
            note:      note }
        end
      # end
      result
    end

    def sysex!(*payload)
      fail NoOutputAllowedError unless output_enabled?
      msg = sysex_msg(payload)
      logger.debug { "#{msg.length}: 0x#{msg.map { |b| '%02X' % b }.join(' ')}" }
      # @mutex_o.synchronize do
        @output.send_message(msg)
      # end
      nil
    end

  protected

    def sysex_prefix; [0xF0]; end
    def sysex_suffix; 0xF7; end
    def sysex_msg(*payload); (sysex_prefix + [payload, sysex_suffix]).flatten.compact; end

    def create_input_device(opts)
      device = create_device(opts, :input, RtMidi::In)
      device.receive_channel_message do |*bytes|
        @messages << bytes
      end
      device
    end

    def create_output_device(opts); create_device(opts, :output, RtMidi::Out); end

    def create_device(opts, kind, device_class)
      return nil unless opts[kind]
      device      = device_class.new
      name_pat    = /#{Regexp.escape(opts[:device_name] || @name)}/
      port_index  = nil
      device.port_names.each_with_index do |name, index|
        if name.match(name_pat)
          port_index = index
          break
        end
      end

      fail SurfaceMaster::NoSuchDeviceError unless port_index

      device.open_port(port_index)
      device
    end

    def message(status, data1, data2); [status, data1, data2]; end
  end
end
