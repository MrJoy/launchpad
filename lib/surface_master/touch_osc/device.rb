module SurfaceMaster
  module TouchOSC
    # Low-level interface to TouchOSC Bridge
    class Device < SurfaceMaster::Device
      def initialize(opts = nil)
        @name = "TouchOSC Bridge"
        super(opts)
        reset!
      end

      def reset!
      end

      def read
        super
          .map { |input| decode_input(input) }
          .compact
      end

      def write(messages)
        @output.write(Array(messages))
      end

    protected

      # def sysex_prefix; @sysex_prefix ||= super + []; end

      def decode_input(input)
        puts input.inspect
        nil
      end
    end
  end
end
