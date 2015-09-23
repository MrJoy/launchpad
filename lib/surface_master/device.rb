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
      @input      = create_input_device(opts)
      @output     = create_output_device(opts)
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
      fail SurfaceMaster::NoInputAllowedError unless input_enabled?

      Array(@input.read(16)).collect do |midi_message|
        (code, note, velocity) = midi_message[:message]
        { timestamp: midi_message[:timestamp],
          state:     (velocity == 127) ? :down : :up,
          velocity:  velocity,
          code:      code,
          note:      note }
      end
    end

  protected

    def sysex_prefix; [0xF0]; end
    def sysex_suffix; 0xF7; end
    def sysex_msg(*payload); (sysex_prefix + [payload, sysex_suffix]).flatten.compact; end

    def sysex_old!(*payload)
      fail NoOutputAllowedError unless output_enabled?
      msg = sysex_msg(payload)
      result = @output.write_sysex(msg)
      if result != 0
        logger.error { "Sysex Error: #{Portmidi::PM_Map.Pm_GetErrorText(result)}" }
      end
      result
    end

    def sysex!(*payload)
      sysex_new!(payload)
    end

    LEN = 4
    def sysex_new!(*payload)
      fail NoOutputAllowedError unless output_enabled?
      msg = sysex_msg(payload)
      messages = []
      loop do
        messages = []
        chunk = msg.slice!(0..125)
        break if chunk.length == 0
        chunk = chunk + [0x00]
        loop do
          piece = chunk.slice!(0..(LEN - 1))
          break if piece.length == 0
          # padded = piece + ([0x00] * (LEN - piece.length))
          messages << { message: piece, timestamp: 0 }
        end
        loop do
          batch = messages.slice!(0..15)
          break if batch.length == 0
          # puts "#{batch.length} / #{messages.length}"
          result = @output.write(batch)
          sleep 0.1 # if messages.length > 0
          # read
          if result != 0
            logger.error { "Sysex Error: #{Portmidi::PM_Map.Pm_GetErrorText(result)}" }
            return result
          end
        end
        sleep 0.1
      end
      0
    end

    def format_msg(msg)
      "0x#{msg.map { |b| '%02X' % b }.join(' ')} (len = #{msg.length})"
    end

    def create_input_device(opts)
      return nil unless opts[:input]
      create_device(Portmidi.input_devices,
                    Portmidi::Input,
                    id:   opts[:input_device_id],
                    name: opts[:device_name])
    end

    def create_output_device(opts)
      return nil unless opts[:output]
      create_device(Portmidi.output_devices,
                    Portmidi::Output,
                    id:   opts[:output_device_id],
                    name: opts[:device_name])
    end

    def create_device(devices, device_type, opts)
      id = opts[:id] || find_device_id(devices, opts[:name])
      fail SurfaceMaster::NoSuchDeviceError if id.nil?
      device_type.new(id)
    rescue RuntimeError => e # TODO: Uh, this should be StandardException, perhaps?
      raise SurfaceMaster::DeviceBusyError, e
    end

    def find_device_id(devices, name)
      name    ||= @name
      device    = devices.find { |dev| dev.name == name }
      id        = device.device_id unless device.nil?
      id
    end

    def message(status, data1, data2); { message: [status, data1, data2], timestamp: 0 }; end
  end
end
