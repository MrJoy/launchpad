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
      def decode_shoulder(note, _velocity); ControlCenter::Orbit::Device::SHOULDERS[note]; end
      def decode_pad(note, _velocity); { button: note }; end
      def decode_knob(note, velocity); { bank: note + 1, value: velocity }; end

      def decode_control(note, velocity)
        tmp         = ControlCenter::Orbit::Device::COLLECTIONS[note]
        tmp[:index] = velocity
        tmp
      end

      def enrich_decoded_message(decoded, note, velocity, timestamp)
        case decoded[:type]
        when :shoulder then decoded.merge!(decode_shoulder(note, velocity))
        when :pad then      decoded.merge!(decode_pad(note, velocity))
        when :knob then     decoded.merge!(decode_knob(note, velocity))
        when :control then  decoded.merge!(decode_control(note, velocity))
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
