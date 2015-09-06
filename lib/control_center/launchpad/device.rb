module ControlCenter
  module Launchpad
    class Device < ControlCenter::Device
      include MIDICodes

      # TODO: Rename scenes to match Mk2
      CODE_NOTE_TO_TYPE = Hash.new { |*_| :grid }
                          .merge([Status::ON, Scene::SCENE1]     => :scene1,
                                 [Status::ON, Scene::SCENE2]     => :scene2,
                                 [Status::ON, Scene::SCENE3]     => :scene3,
                                 [Status::ON, Scene::SCENE4]     => :scene4,
                                 [Status::ON, Scene::SCENE5]     => :scene5,
                                 [Status::ON, Scene::SCENE6]     => :scene6,
                                 [Status::ON, Scene::SCENE7]     => :scene7,
                                 [Status::ON, Scene::SCENE8]     => :scene8,
                                 [Status::CC, Control::UP]       => :up,
                                 [Status::CC, Control::DOWN]     => :down,
                                 [Status::CC, Control::LEFT]     => :left,
                                 [Status::CC, Control::RIGHT]    => :right,
                                 [Status::CC, Control::SESSION]  => :session,
                                 [Status::CC, Control::USER1]    => :user1,
                                 [Status::CC, Control::USER2]    => :user2,
                                 [Status::CC, Control::MIXER]    => :mixer)
                          .freeze
      TYPE_TO_NOTE      = { up:      Control::UP,
                            down:    Control::DOWN,
                            left:    Control::LEFT,
                            right:   Control::RIGHT,
                            session: Control::SESSION,
                            user1:   Control::USER1,
                            user2:   Control::USER2,
                            mixer:   Control::MIXER,
                            scene1:  Scene::SCENE1, # Volume
                            scene2:  Scene::SCENE2, # Pan
                            scene3:  Scene::SCENE3, # Send A
                            scene4:  Scene::SCENE4, # Send B
                            scene5:  Scene::SCENE5, # Stop
                            scene6:  Scene::SCENE6, # Mute
                            scene7:  Scene::SCENE7, # Solo
                            scene8:  Scene::SCENE8 }.freeze # Record Arm

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

      def change(opts = nil)
        opts ||= {}
        command, payload = color_payload(opts)
        sysex!(command, payload[:led], payload[:color])
      end

      def changes(values)
        msg_by_command = {}
        values.each do |value|
          command, payload = color_payload(value)
          (msg_by_command[command] ||= []) << payload
        end
        msg_by_command.each do |command, payloads|
          # The documented batch size for RGB LED updates is 80.  The docs lie, at least on my current
          # firmware version -- anything above 62 crashes the device hard.
          while (slice = payloads.shift(62)).length > 0
            sysex!(command, *slice.map { |payload| [payload[:led], payload[:color]] })
          end
        end
      end

      def read
        super.collect do |input|
          note          = input[:note]
          input[:type]  = CODE_NOTE_TO_TYPE[[input[:code], note]] || :grid
          if input[:type] == :grid
            note      = note - 11
            input[:x] = note % 10
            input[:y] = note / 10
          end
          input
        end
      end

    protected

      def layout!(mode); sysex!(0x22, mode); end
      def sysex_prefix; @sysex_prefix ||= super + [0x00, 0x20, 0x29, 0x02, 0x18]; end

      def decode_led(opts)
        case
        when opts[:cc]
          [:cc, TYPE_TO_NOTE[opts[:cc]]]
        when opts[:grid]
          if opts[:grid] == :all
            [:all, nil]
          else
            [:grid, (opts[:grid][1] * 10) + opts[:grid][0] + 11]
          end
        when opts[:column]
          [:column, opts[:column]]
        when opts[:row]
          [:row, opts[:row]]
        end
      end

      TYPE_TO_COMMAND = { cc:     0x0B,
                          grid:   0x0B,
                          column: 0x0C,
                          row:    0x0D,
                          all:    0x0E }.freeze
      def color_payload(opts)
        type, led = decode_led(opts)
        command   = TYPE_TO_COMMAND[type]
        case type
        when :cc, :grid
          color   = [opts[:red] || 0x00, opts[:green] || 0x00, opts[:blue] || 0x00]
        when :column, :row, :all
          color   = opts[:color] || 0x00
        end
        [command, { led: led, color: color }]
      end

      def output!(status, data1, data2)
        outputs!(message(status, data1, data2))
      end

      def outputs!(*messages)
        messages = Array(messages)
        if @output.nil?
          logger.error "trying to write to device that's not been initialized for output"
          raise ControlCenter::NoOutputAllowedError
        end
        logger.debug "writing messages to launchpad:\n  #{messages.join("\n  ")}" if logger.debug?
        @output.write(messages)
        nil
      end

      def note(type, opts)
        note = TYPE_TO_NOTE[type]
        if note.nil?
          x = (opts[:x] || -1).to_i
          y = (opts[:y] || -1).to_i
          if x < 0 || x > 7 || y < 0 || y > 7
            logger.error "wrong coordinates specified: x=#{x}, y=#{y}"
            raise NoValidGridCoordinatesError.new("you need to specify valid coordinates (x/y, 0-7, from top left), you specified: x=#{x}, y=#{y}")
          end
          note = y * 10 + x
        end
        note
      end
    end
  end
end
