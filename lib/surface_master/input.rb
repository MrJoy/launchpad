module SurfaceMaster
  # Clas representing an individual input event.
  class Input
    attr_reader :event, :x, :y, :raw
    def initialize(event:, x:, y:, raw: nil)
      @event  = event
      @x      = x
      @y      = y
      @raw    = raw
    end

    def to_s
      tmp = "<#{event}@#{x}x#{y}"
      tmp += ";raw=#{raw.inspect}" if raw
      tmp += ">"
      tmp
    end
  end
end
