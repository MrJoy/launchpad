module SurfaceMaster
  module Launchpad
    # Low-level interface to Novation Launchpad Mark 2 control surface.
    class Device < SurfaceMaster::Device
      include MIDICodes

      def initialize(opts = nil)
        @name = "Launchpad MK2"
        super(opts)
        reset! if output_enabled?
        raw         = (0..8)
                      .map { |x| (0..8).map { |y| encode_grid_coord([x, y]) } }
                      .map { |coord| [coord, [0x00, 0x00, 0x00]] }
                      .flatten
        @next_grid  = Hash[raw.map { |coord| [coord, [0x00, 0x00, 0x00]] }]
        @old_grid   = Hash[raw.map { |coord| [coord, [0x00, 0x00, 0x00]] }]
      end

      def reset!
        # TODO: Suss out what this should be for the Mark 2.
        layout!(0x00)
        send!([message(Status::CC, Status::NIL, Status::NIL)])
      end

      # TODO: Support more of the LaunchPad Mark 2's functionality.

      def []=(coord, color)
        raise NoOutputAllowedError unless output_enabled?
        mapped_coord = encode_grid_coord(coord)
        return unless mapped_coord
        @next_grid[encode_grid_coord(coord)] = color
      end

      def [](coord)
        @next_grid[encode_grid_coord(coord)].dup
      end

      def commit!
        raise NoOutputAllowedError unless output_enabled?
        dirty_keys  = @next_grid
                      .keys
                      .select { |k| @next_grid[k] != @old_grid[k] }
        changes     = dirty_keys.map { |k| [k, @next_grid[k]] }
        changes.each do |(k, v)|
          @old_grid[k] = v
        end
        apply(changes)
      end

      def read
        raise NoInputAllowedError unless input_enabled?
        super.collect do |raw|
          coord = decode_grid_coord(raw[:code], raw[:note])
          Input.new(event:  raw[:state],
                    x:      coord[0],
                    y:      coord[1],
                    raw:    logger.debug? ? raw : nil)
        end
      end

    protected

      def apply(values)
        # The documented batch size for RGB LED updates is 80.  The docs lie, at least on my
        # current firmware version -- anything above 62 crashes the device hard.
        values.shift(62).each do |slice|
          # 0x0B is the command for setting individual LEDs.
          # Other interesting commands include:
          #   0x0C -> Column
          #   0x0D -> Row
          #   0x0E -> All LEDs
          sysex!(0x0B, *slice)
        end
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

      def encode_grid_coord(coord)
        return nil unless valid_coord?(coord)
        if coord[1] == 0
          coord[0] + 104
        else
          ((8 - coord[1]) * 10) + coord[0] + 11
        end
      end

      def valid_coord?(coord)
        !(coord[0] < 0 || coord[0] > 8 ||
          coord[1] < 0 || coord[1] > 8 ||
          (coord[1] == 0 && coord[0] > 7))
      end

      def layout!(mode); sysex!(0x22, mode); end
      def sysex_prefix; @sysex_prefix ||= super + [0x00, 0x20, 0x29, 0x02, 0x18]; end

      # def check_xy_values!(xy_pair)
      #   x = xy_pair[0]
      #   y = xy_pair[1]
      #   return unless xy_pair.length != 2 ||
      #                 !coord_in_range?(x) ||
      #                 !coord_in_range?(y)

      #   raise SurfaceMaster::Launchpad::NoValidGridCoordinatesError
      # end

      # def coord_in_range?(val); val && val >= 0 && val <= 7; end

      def send!(messages)
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
