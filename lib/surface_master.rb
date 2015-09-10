require "unimidi"
require "logger"

# APIs to enable access to various MIDI-based control surfaces.
module SurfaceMaster
  # TODO: I'm not needed anymore if we're ditching Portmidi!
  def self.init!
    @initialized ||= begin
      true
    end
  end
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
