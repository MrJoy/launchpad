# APIs to enable access to various MIDI-based control surfaces.
module ControlCenter
end

require "portmidi"

# Monkey-patch portmidi to handle messages longer than 4 bytes, as sent by
# things like the Numark Orbit.
# module Portmidi
#   module PM_Map
#     class Event < FFI::Struct
#       layout :message, :int64,
#              :timestamp, :int32
#     end
#   end
# end


# module Portmidi
#   class Input
#   private
#     def parseEvent(event)
#       {
#         :raw => event[:message],
#         :message => [
#           ((event[:message]) & 0xFF),
#           (((event[:message]) >> 8) & 0xFF),
#           (((event[:message]) >> 16) & 0xFF),
#           (((event[:message]) >> 24) & 0xFF),
#           (((event[:message]) >> 32) & 0xFF),
#           (((event[:message]) >> 48) & 0xFF),
#           (((event[:message]) >> 56) & 0xFF),
#           (((event[:message]) >> 64) & 0xFF),
#         ],
#         :timestamp => event[:timestamp]
#       }
#     end
#   end
# end

# All the fun of launchpad in one module!
#
# See Launchpad::Device for basic access to launchpad input/ouput
# and Launchpad::Interaction for advanced interaction features.
#
# The following parameters will be used throughout the library, so here are the ranges:
#
# [+type+]              type of the button, one of
#                       <tt>
#                       :grid,
#                       :up, :down, :left, :right, :session, :user1, :user2, :mixer,
#                       :scene1 - :scene8
#                       </tt>
# [<tt>x/y</tt>]        x/y coordinate (used when type is set to :grid),
#                       <tt>0-7</tt> (from left to right/top to bottom),
#                       mandatory when +type+ is set to <tt>:grid</tt>
# [<tt>red/green</tt>]  brightness of the red/green LED,
#                       can be set to one of four levels:
#                       * off (<tt>:off, 0</tt>)
#                       * low brightness (<tt>:low, :lo, 1</tt>)
#                       * medium brightness (<tt>:medium, :med, 2</tt>)
#                       * full brightness (<tt>:high, :hi, 3</tt>)
#                       optional, defaults to <tt>:off</tt>
# [+mode+]              button mode,
#                       one of
#                       * <tt>:normal</tt>
#                       * <tt>:flashing</tt> (LED is marked as flashing, see Launchpad::Device.flashing_on, Launchpad::Device.flashing_off and Launchpad::Device.flashing_auto)
#                       * <tt>:buffering</tt> (LED is written to buffer, see Launchpad::Device.start_buffering, Launchpad::Device.flush_buffer)
#                       optional, defaults to <tt>:normal</tt>
# [+state+]             whether the button is pressed or released, <tt>:down/:up</tt>
module Launchpad
end

require "errors"
require "logging"
require "launchpad/interaction"
require "orbit/device"
