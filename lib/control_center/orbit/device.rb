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
        # Colors:
        # 0x00 == Off                 >0000 0000
        # 0x01 == Dark Blue           >0000 0001
        # 0x02 == Blue                >0000 0010
        # 0x03 == Light Blue          >0000 0011

        # 0x04 == Green               >0000 0100
        # 0x05 == Cyan                >0000 0101
        # 0x06 == Light Sky Blue      >0000 0110
        # 0x07 == Sky Blue            >0000 0111
        # 0x08 == Green               >0000 1000
        # 0x09 == Greenish Cyan       >0000 1001
        # 0x0A == Bright Cyan         >0000 1010

        # 0x10 == Red                 >0001 0000
        # 0x11 == Magenta             >0001 0001
        # 0x12 == Violet              >0001 0010
        # 0x13 == Purple              >0001 0011
        # 0x14 == Yellow              >0001 0100

        # ...

        # 0x3F == White               >0001 1111

        reset_message = [0x01, 0x70,
                         0x00, 0x00, 0x00,
                         0x00, 0x04, 0x00,
                         0x00, 0x08, 0x00,
                         0x00, 0x0C, 0x00,
                         0x00, 0x01, 0x00,
                         0x00, 0x05, 0x00,
                         0x00, 0x09, 0x00,
                         0x00, 0x0D, 0x00,
                         0x00, 0x02, 0x00,
                         0x00, 0x06, 0x00,
                         0x00, 0x0A, 0x00,
                         0x00, 0x0E, 0x00,
                         0x00, 0x03, 0x00,
                         0x00, 0x07, 0x00,
                         0x00, 0x0B, 0x00,
                         0x00, 0x0F, 0x00,
                         0x01, 0x00, 0x00,
                         0x01, 0x04, 0x00,
                         0x01, 0x08, 0x00,
                         0x01, 0x0C, 0x00,
                         0x01, 0x01, 0x00,
                         0x01, 0x05, 0x00,
                         0x01, 0x09, 0x00,
                         0x01, 0x0D, 0x00,
                         0x01, 0x02, 0x00,
                         0x01, 0x06, 0x00,
                         0x01, 0x0A, 0x00,
                         0x01, 0x0E, 0x00,
                         0x01, 0x03, 0x00,
                         0x01, 0x07, 0x00,
                         0x01, 0x0B, 0x00,
                         0x01, 0x0F, 0x00,
                         0x02, 0x00, 0x00,
                         0x02, 0x04, 0x00,
                         0x02, 0x08, 0x00,
                         0x02, 0x0C, 0x00,
                         0x02, 0x01, 0x00,
                         0x02, 0x05, 0x00,
                         0x02, 0x09, 0x00,
                         0x02, 0x0D, 0x00,
                         0x02, 0x02, 0x00,
                         0x02, 0x06, 0x00,
                         0x02, 0x0A, 0x00,
                         0x02, 0x0E, 0x00,
                         0x02, 0x03, 0x00,
                         0x02, 0x07, 0x00,
                         0x02, 0x0B, 0x00,
                         0x02, 0x0F, 0x00,
                         0x03, 0x00, 0x00,
                         0x03, 0x04, 0x00,
                         0x03, 0x08, 0x00,
                         0x03, 0x0C, 0x00,
                         0x03, 0x01, 0x00,
                         0x03, 0x05, 0x00,
                         0x03, 0x09, 0x00,
                         0x03, 0x0D, 0x00,
                         0x03, 0x02, 0x00,
                         0x03, 0x06, 0x00,
                         0x03, 0x0A, 0x00,
                         0x03, 0x0E, 0x00,
                         0x03, 0x03, 0x00,
                         0x03, 0x07, 0x00,
                         0x03, 0x0B, 0x00,
                         0x03, 0x0F, 0x00,
                         0x00, 0x00, 0x01,
                         0x00, 0x02, 0x00,
                         0x03, 0x00, 0x00,
                         0x01, 0x01, 0x01,
                         0x02, 0x01, 0x03,
                         0x01, 0x00, 0x02,
                         0x01, 0x02, 0x02,
                         0x02, 0x03, 0x02,
                         0x00, 0x03, 0x01,
                         0x03, 0x02, 0x03,
                         0x03, 0x03, 0x0C,
                         0x00, 0x0D, 0x00,
                         0x0C, 0x00, 0x0D,
                         0x00, 0x0C, 0x00,
                         0x0D, 0x00, 0x0C,
                         0x00, 0x0D, 0x00]
        sysex!(*reset_message)
        sysex!(0x00, 0x00)
        sysex!(*reset_message)
      end

      def read
        super.map do |input|
          decode_input(input)
        end
      end

    protected

      def sysex_prefix; @sysex_prefix ||= super + [0x00, 0x01, 0x3F, 0x2B, 0x03]; end

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
        when :shoulder  then decoded = decode_shoulder(decoded, note, velocity)
        when :pad       then decoded = decode_pad(decoded, note, velocity)
        when :knob      then decoded = decode_knob(decoded, note, velocity)
        when :control   then decoded = decode_control(decoded, note, velocity)
        end
        decoded[:timestamp] = timestamp
        decoded
      end

      def decode_input(input)
        puts [input[:code].to_hex, input[:note].to_hex, input[:velocity].to_hex].join(" ")
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
