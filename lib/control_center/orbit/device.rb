module ControlCenter
  module Orbit
    class Device < ControlCenter::Device
      include MIDICodes

      def initialize(opts = nil)
        super(opts)
        reset!
      end

      def reset!
        # TODO: Implement me.
      end

      def read
        super.map do |input|
          decode_input(input)
        end
      end

    protected
      def decode_shoulder(decoded, note, _velocity)
        decoded[:control].merge!(ControlCenter::Orbit::Device::SHOULDERS[note])
        decoded
      end

      def decode_pad(decoded, note, _velocity)
        decoded[:control][:button] = note
        decoded
      end

      def decode_knob(decoded, note, velocity)
        decoded[:control][:bank] = note + 1
        decoded[:value] = velocity
        decoded
      end

      def decode_control(decoded, note, velocity)
        tmp         = ControlCenter::Orbit::Device::SELECTORS[note]
        tmp[:index] = velocity
        decoded[:control].merge!(tmp)
        decoded
      end

      def enrich_decoded_message(decoded, note, velocity, timestamp)
        case decoded[:type]
        when :shoulder then decoded = decode_shoulder(decoded, note, velocity)
        when :pad then      decoded = decode_pad(decoded, note, velocity)
        when :knob then     decoded = decode_knob(decoded, note, velocity)
        when :control then  decoded = decode_control(decoded, note, velocity)
        end
        decoded[:timestamp] = timestamp
        decoded
      end

      def decode_input(input)
        note      = input[:note]
        velocity  = input[:velocity]
        code_high = input[:code] & 0xF0
        code_low  = input[:code] & 0x0F
        raw       = ControlCenter::Orbit::Device::CONTROLS[code_high][code_low]
        enrich_decoded_message(raw, note, velocity, input[:timestamp])
      end
    end
  end
end
