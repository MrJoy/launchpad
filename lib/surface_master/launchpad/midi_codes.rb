module SurfaceMaster
  module Launchpad
    module MIDICodes
      # Module defining MIDI status codes.
      # TODO: Some of these are fairly generic?  Can we hoist them?
      module Status
        NIL           = 0x00
        OFF           = 0x80
        ON            = 0x90
        MULTI         = 0x92
        CC            = 0xB0
      end

      # Module defininig MIDI data 1 (note) codes for control buttons.
      module Control
        UP            = 0x68
        DOWN          = 0x69
        LEFT          = 0x6A
        RIGHT         = 0x6B
        SESSION       = 0x6C
        USER1         = 0x6D
        USER2         = 0x6E
        MIXER         = 0x6F
      end

      # Module defininig MIDI data 1 (note) codes for scene buttons.  These are just the last column
      # in the grid.
      module Scene
        VOLUME        = 0x59
        PAN           = 0x4f
        SEND_A        = 0x45
        SEND_B        = 0x3b
        STOP          = 0x31
        MUTE          = 0x27
        SOLO          = 0x1d
        RECORD_ARM    = 0x13
      end

      # Module defining MIDI data 2 (velocity) codes.
      module Velocity
        TEST_LEDS     = 0x7C
      end

      # Module defining MIDI data 2 codes for selecting the grid layout.
      module GridLayout
        XY            = 0x01
        DRUM_RACK     = 0x02
      end
    end
  end
end
