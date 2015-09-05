require "portmidi"
require "logger"

# APIs to enable access to various MIDI-based control surfaces.
module ControlCenter
  def self.init!
    @initialized ||= begin
      Portmidi.start
      true
    end
  end
end

require "control_center/version"
require "control_center/errors"
require "control_center/logging"
require "control_center/device"
require "control_center/interaction"

require "control_center/launchpad/errors"
require "control_center/launchpad/midi_codes"
require "control_center/launchpad/device"
require "control_center/launchpad/interaction"

require "control_center/orbit/midi_codes"
require "control_center/orbit/device"
