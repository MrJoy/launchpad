module SurfaceMaster
  module Orbit
    # This module provides mapping information to help us decode messages from the Numark Orbit.
    #
    # This is all predicated upon our fixed mapping being applied.
    module MIDICodes
      # TODO: Use a lib to do a deep-freeze.
      # rubocop:disable Metrics/LineLength
      CONTROLS    = { 0x90 => { 0x00 => { type: :pad,           state: :down,    control: { bank: 1 } },
                                0x01 => { type: :pad,           state: :down,    control: { bank: 2 } },
                                0x02 => { type: :pad,           state: :down,    control: { bank: 3 } },
                                0x03 => { type: :pad,           state: :down,    control: { bank: 4 } },
                                0x0F => { type: :shoulder,      state: :down,    control: {} } },
                      0x80 => { 0x00 => { type: :pad,           state: :up,      control: { bank: 1 } },
                                0x01 => { type: :pad,           state: :up,      control: { bank: 2 } },
                                0x02 => { type: :pad,           state: :up,      control: { bank: 3 } },
                                0x03 => { type: :pad,           state: :up,      control: { bank: 4 } },
                                0x0F => { type: :shoulder,      state: :up,      control: {} } },
                      0xB0 => { 0x00 => { type: :knob,          state: :update,  control: { vknob: 1 } },
                                0x01 => { type: :knob,          state: :update,  control: { vknob: 2 } },
                                0x02 => { type: :knob,          state: :update,  control: { vknob: 3 } },
                                0x03 => { type: :knob,          state: :update,  control: { vknob: 4 } },
                                0x0C => { type: :accelerometer, state: :tilt,    control: { axis: :x } },
                                0x0D => { type: :accelerometer, state: :tilt,    control: { axis: :y } },
                                0x0F => { type: :control,       state: :switch,  control: {} } } }.freeze
      # rubocop:enable Metrics/LineLength
      SHOULDERS   = { 0x03 => { button: :left },
                      0x04 => { button: :right } }.freeze
      SELECTORS   = { 0x01 => { selector: :banks },
                      0x02 => { selector: :vknobs } }.freeze
    end
  end
end
