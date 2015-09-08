module SurfaceMaster
  module Orbit
    # This module provides mapping information to help us decode messages from the Numark Orbit.
    #
    # This is all predicated upon our fixed mapping being applied.
    module MIDICodes
      # TODO: Use a lib to do a deep-freeze.
      CONTROLS    = { 0x90 => { 0x00 => { type: :pad,           action: :down,    control: { bank: 1 } },
                                0x01 => { type: :pad,           action: :down,    control: { bank: 2 } },
                                0x02 => { type: :pad,           action: :down,    control: { bank: 3 } },
                                0x03 => { type: :pad,           action: :down,    control: { bank: 4 } },
                                0x0F => { type: :shoulder,      action: :down,    control: {} } },
                      0x80 => { 0x00 => { type: :pad,           action: :up,      control: { bank: 1 } },
                                0x01 => { type: :pad,           action: :up,      control: { bank: 2 } },
                                0x02 => { type: :pad,           action: :up,      control: { bank: 3 } },
                                0x03 => { type: :pad,           action: :up,      control: { bank: 4 } },
                                0x0F => { type: :shoulder,      action: :up,      control: {} } },
                      0xB0 => { 0x00 => { type: :knob,          action: :update,  control: { vknob: 1 } },
                                0x01 => { type: :knob,          action: :update,  control: { vknob: 2 } },
                                0x02 => { type: :knob,          action: :update,  control: { vknob: 3 } },
                                0x03 => { type: :knob,          action: :update,  control: { vknob: 4 } },
                                0x0C => { type: :accelerometer, action: :tilt,    control: { axis: :x } },
                                0x0D => { type: :accelerometer, action: :tilt,    control: { axis: :y } },
                                0x0F => { type: :control,       action: :switch,  control: {} } } }.freeze
      SHOULDERS   = { 0x03 => { button: :left },
                      0x04 => { button: :right } }.freeze
      SELECTORS   = { 0x01 => { selector: :banks },
                      0x02 => { selector: :vknobs } }.freeze
    end
  end
end
