module SurfaceMaster
  module Orbit
    # Low-level interface to Numark Orbit wireless MIDI control surface.
    class Device < SurfaceMaster::Device
      include MIDICodes

      def initialize(opts = nil)
        @name = "Numark ORBIT"
        super(opts)
        init!
      end

      def reset!; end

      def init!
        # Hack to get around apparent portmidi message truncation.
        return

        # Skip Sysex begin, vendor header, command code, aaaaand sysex end --
        # this will let us compare command vs. response payloads to determine
        # if the state of the device is what we want.  Of course, sometimes it
        # lies, but we can't do much about that.
        # expected_state = MAPPINGS[1..-1]
        # sysex!(MAPPINGS)
        # sleep 0.1
        # sysex!(READ_STATE)
        # current_state       = []
        # started_at          = Time.now.to_f
        # attempts            = 1
        # state               = :looking_for_start
        # loop do
        #   raw = @input.read
        #   unless raw
        #     elapsed = Time.now.to_f - started_at
        #     if elapsed > 4.0
        #       logger.error { "Timeout fetching state of Numark Orbit!" }
        #       break
        #     elsif elapsed > (1.0 * attempts)
        #       logger.error { "Asking for current state of Numark Orbit again!" }
        #       attempts     += 1
        #       current_state = []
        #       state         = :looking_for_start
        #       sysex!(READ_STATE)
        #       next
        #     end
        #     sleep 0.01
        #     next
        #   end

        #   case state
        #   when :looking_for_start
        #     idx = raw.find_index { |ii| ii[:message][0] == 0xF0 }
        #     if idx
        #       state           = :looking_for_end
        #       raw             = raw[idx..-1]
        #       current_state  += raw.map { |ii| ii[:message] }.flatten
        #     end
        #   when :looking_for_end
        #     idx = raw.find_index { |ii| ii[:message][0] == 0xF7 }
        #     if idx
        #       # TODO: Now what?
        #       current_state = current_state[6..-1]
        #       if expected_state != current_state
        #         logger.error { "UH OH!  Numark Orbit state didn't match what we sent!" }
        #         logger.error { "Expected: #{format_msg(expected_state)}" }
        #         logger.error { "Got:      #{format_msg(current_state)}" }
        #       else
        #         logger.debug { "Your Numark Orbit should be in the right state now." }
        #         return
        #       end
        #     else
        #       idx = -1
        #     end
        #     raw             = raw[0..idx]
        #     current_state  += raw.map { |ii| ii[:message] }.flatten
        #   end
        # end

        # logger.error { "Didn't get state from Numark Orbit!" }
      end

      def read
        super
          .map { |input| decode_input(input) }
          .compact
      end

    protected

      MAPPINGS =   [0x03, 0x01, 0x70,

                    # Pad mappings.  (Channel, Note, Color) for banks 1-4.
                    # These are addressed left-to-right, top-to-bottom.
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
                    0x02, 0x0D, 0x00, # After here is where shit goes sideways...
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

                    # VKnob buttons, I think.  Not sure of mapping, or how abs
                    #vs. relative fits in.
                    0x00, 0x00,
                    0x01, 0x00,
                    0x02, 0x00,
                    0x03, 0x00,

                    0x00, 0x01,
                    0x01, 0x01,
                    0x02, 0x01,
                    0x03, 0x01,

                    0x00, 0x02,
                    0x01, 0x02,
                    0x02, 0x02,
                    0x03, 0x02,

                    0x00, 0x03,
                    0x01, 0x03,
                    0x02, 0x03,
                    0x03, 0x03,

                    # Shoulder buttons.  Channel/CC pairs for left, then right
                    # through each of the four banks.
                    0x0C, 0x00,
                    0x0D, 0x00,

                    0x0C, 0x00,
                    0x0D, 0x00,

                    0x0C, 0x00,
                    0x0D, 0x00,

                    0x0C, 0x00,
                    0x0D, 0x00]
      READ_STATE = [0x01, 0x00, 0x00]

      def sysex_prefix; @sysex_prefix ||= super + [0x00, 0x01, 0x3F, 0x2B]; end

      def decode_shoulder(decoded, note, _velocity)
        decoded[:control] = decoded[:control].merge(SurfaceMaster::Orbit::Device::SHOULDERS[note])
        decoded
      end

      def decode_grid(decoded, note, _velocity)
        decoded[:control] = decoded[:control].merge(x: note / 4, y: note % 4)
        decoded
      end

      def decode_knob(decoded, note, velocity)
        decoded[:control] = decoded[:control].merge(bank: note)
        decoded[:value]   = velocity
        decoded
      end

      def decode_control(decoded, note, velocity)
        decoded           = decoded.merge(SurfaceMaster::Orbit::Device::SELECTORS[note])
        decoded[:control] = { button: velocity }
        decoded
      end

      def decode_accelerometer(decoded, _note, velocity)
        decoded[:value] = velocity
        decoded
      end

      def enrich_decoded_message(decoded, note, velocity, timestamp)
        case decoded[:type]
        when :shoulder      then decoded = decode_shoulder(decoded, note, velocity)
        when :grid          then decoded = decode_grid(decoded, note, velocity)
        when :vknob         then decoded = decode_knob(decoded, note, velocity)
        when :accelerometer then decoded = decode_accelerometer(decoded, note, velocity)
        else decoded = decode_control(decoded, note, velocity)
        end
        decoded[:timestamp] = timestamp
        decoded
      end

      def decode_input(input)
        note      = input[:note]
        velocity  = input[:velocity]
        code_high = input[:code] & 0xF0
        code_low  = input[:code] & 0x0F
        raw       = SurfaceMaster::Orbit::Device::CONTROLS[code_high]
        raw       = raw[code_low] if raw
        raw       = enrich_decoded_message(raw.dup, note, velocity, input[:timestamp]) if raw
        raw
      end
    end
  end
end
