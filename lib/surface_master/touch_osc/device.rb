module SurfaceMaster
  module TouchOSC
    # Low-level interface to TouchOSC Bridge
    class Device < SurfaceMaster::Device
      def initialize(opts = nil, &mapper)
        @name = "TouchOSC Bridge"
        super(opts)
        @mapper = mapper || proc { |input| input }
      end

      def reset!
      end

      def read
        super
          .map { |input| @mapper.call(input) }
          .compact
      end

      def write(messages)
        @output.write(Array(messages))
      end

    protected

      # def sysex_prefix; @sysex_prefix ||= super + []; end
    end
  end
end
