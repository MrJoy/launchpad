module ControlCenter
  module Orbit
    # This module provides mapping information to help us decode messages from the Numark Orbit.
    #
    # This is all predicated upon our fixed mapping being applied.
    module MIDICodes
      # TODO: Use a lib to do a deep-freeze.
      CONTROLS    = { 0x90 => { 0x00 => { type: :pad,           action: :down,    bank: 1 },
                                0x01 => { type: :pad,           action: :down,    bank: 2 },
                                0x02 => { type: :pad,           action: :down,    bank: 3 },
                                0x03 => { type: :pad,           action: :down,    bank: 4 },
                                0x0F => { type: :shoulder,      action: :down } },
                      0x80 => { 0x00 => { type: :pad,           action: :up,      bank: 1 },
                                0x01 => { type: :pad,           action: :up,      bank: 2 },
                                0x02 => { type: :pad,           action: :up,      bank: 3 },
                                0x03 => { type: :pad,           action: :up,      bank: 4 },
                                0x0F => { type: :shoulder,      action: :up } },
                      0xB0 => { 0x00 => { type: :knob,          action: :update,  vknob: 1 },
                                0x01 => { type: :knob,          action: :update,  vknob: 2 },
                                0x02 => { type: :knob,          action: :update,  vknob: 3 },
                                0x03 => { type: :knob,          action: :update,  vknob: 4 },
                                0x0C => { type: :accelerometer, action: :tilt,    axis: :x },
                                0x0D => { type: :accelerometer, action: :tilt,    axis: :y },
                                0x0F => { type: :control,       action: :switch } } }.freeze
      SHOULDERS   = { 0x03 => { button: :left },
                      0x04 => { button: :right } }.freeze
      COLLECTIONS = { 0x01 => { collection: :banks },
                      0x02 => { collection: :vknobs } }.freeze
    end
  end
end
