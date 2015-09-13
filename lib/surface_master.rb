# require "unimidi"
require "rtmidi"
require "logger"

# APIs to enable access to various MIDI-based control surfaces.
module SurfaceMaster
end

require "surface_master/version"
require "surface_master/errors"
require "surface_master/logging"
require "surface_master/device"
require "surface_master/interaction"

require "surface_master/launchpad/errors"
require "surface_master/launchpad/midi_codes"
require "surface_master/launchpad/device"
require "surface_master/launchpad/interaction"

require "surface_master/orbit/midi_codes"
require "surface_master/orbit/device"
require "surface_master/orbit/interaction"
