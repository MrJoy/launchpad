module SurfaceMaster
  module Launchpad
    # Low-level interface to Novation Launchpad Mark 2 control surface.
    class Device < SurfaceMaster::Device
      include MIDICodes

      TYPE_TO_NOTE      = { up:         Control::UP,
                            down:       Control::DOWN,
                            left:       Control::LEFT,
                            right:      Control::RIGHT,
                            session:    Control::SESSION,
                            user1:      Control::USER1,
                            user2:      Control::USER2,
                            mixer:      Control::MIXER,
                            volume:     Scene::VOLUME,              # Volume
                            pan:        Scene::PAN,                 # Pan
                            send_a:     Scene::SEND_A,              # Send A
                            send_b:     Scene::SEND_B,              # Send B
                            stop:       Scene::STOP,                # Stop
                            mute:       Scene::MUTE,                # Mute
                            solo:       Scene::SOLO,                # Solo
                            record_arm: Scene::RECORD_ARM }.freeze  # Record Arm

      def initialize(opts = nil)
        @name = "Launchpad MK2"
        super(opts)
        reset! if output_enabled?
      end

      def reset
        # TODO: Suss out what this should be for the Mark 2.
        layout!(0x00)
        output!(Status::CC, Status::NIL, Status::NIL)
      end

      # TODO: Support more of the LaunchPad Mark 2's functionality.

      def changes(values)
        raise NoOutputAllowedError unless output_enabled?

        organize_commands(values).each do |command, payloads|
          # The documented batch size for RGB LED updates is 80.  The docs lie, at least on my
          # current firmware version -- anything above 62 crashes the device hard.
          until (slice = payloads.shift(62)).empty?
            messages = slice.map { |payload| [payload[:led], payload[:color]] }
            sysex!(command, *messages)
          end
        end
        nil
      end

      def read
        raise NoInputAllowedError unless input_enabled?
        super.collect do |raw|
          coord = decode_grid_coord(raw[:code], raw[:note])
          Input.new(event:  raw[:state],
                    x:      coord[0],
                    y:      coord[1])
                    # raw:    raw)
        end
      end

    protected

      def organize_commands(values)
        msg_by_command = {}
        values.each do |value|
          command, payload = color_payload(value)
          (msg_by_command[command] ||= []) << payload
        end
        msg_by_command
      end

      def decode_grid_coord(code, note)
        case code
        when Status::CC
          x = note - 0x68
          y = 0
        else
          note -= 11
          x     = note % 10
          y     = 8 - (note / 10) # We flip this so 0x0 is upper-left, and push it down to make room
                                  # for the CC buttons to be mapped to the grid.
        end
        [x, y]
      end

      def layout!(mode); sysex!(0x22, mode); end
      def sysex_prefix; @sysex_prefix ||= super + [0x00, 0x20, 0x29, 0x02, 0x18]; end

      def decode_led(opts)
        case
        when opts[:cc]      then [:cc, TYPE_TO_NOTE[opts[:cc]]]
        when opts[:grid]    then decode_grid_led(opts)
        when opts[:column]  then [:column, opts[:column]]
        when opts[:row]     then [:row, opts[:row]]
        end
      rescue
        raise SurfaceMaster::Launchpad::NoValidGridCoordinatesError
      end

      def decode_grid_led(opts)
        if opts[:grid] == :all
          [:all, nil]
        else
          check_xy_values!(opts[:grid])
          [:grid, (opts[:grid][1] * 10) + opts[:grid][0] + 11]
        end
      end

      def check_xy_values!(xy_pair)
        x = xy_pair[0]
        y = xy_pair[1]
        return unless xy_pair.length != 2 ||
                      !coord_in_range?(x) ||
                      !coord_in_range?(y)

        raise SurfaceMaster::Launchpad::NoValidGridCoordinatesError
      end

      def coord_in_range?(val); val && val >= 0 && val <= 7; end

      def color_payload(opts)
        # Hard-coded to single-LED RGB update right now.
        # For paletted changes, commands available include:
        # 0x0C -> Column
        # 0x0D -> Row
        # 0x0E -> All LEDs
        [0x0B,
         { led:   decode_led(opts)[1],
           color: [opts[:red] || 0x00, opts[:green] || 0x00, opts[:blue] || 0x00] }]
      end

      def output!(status, data1, data2)
        outputs!(message(status, data1, data2))
      end

      def outputs!(*messages)
        messages = Array(messages)
        if @output.nil?
          logger.error "trying to write to device not open for output"
          raise SurfaceMaster::NoOutputAllowedError
        end
        logger.debug "writing messages to launchpad:\n  #{messages.join("\n  ")}" if logger.debug?
        @output.write(messages)
        nil
      end
    end
  end
end
