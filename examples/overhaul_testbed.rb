#!/usr/bin/env ruby
#
# This file provides an example of using the Novation Launchpad Mark 2 using
# event handlers to respond to buttons, and batch LED updates to update every
# button on the board quite rapidly.
#
# Controls:
#
# * Press any grid button and observe that the color changes to white while it's held.  Any number
#   of pads may be pressed simultaneously.
# * The control buttons on the right will each channel-flip a quadrant of the board.  They act as
#   toggles, to pressing them again undoes the effect.
# * The `Mixer` button will terminate the simulation.
#
# Effects:
#
# * The color of a pad is applied in layers additively, with values clamped to white at the end:
#     1. The base color for each grid pad is defined by its position with the color getting more
#        green on the X axis, and more blue along the Y axis.  See `SCALE` for how steep the change
#        is.
#     2. Each quadrant adds in a specific color (see `QUADRANTS` below).
#     3. The red/green/blue channels may be rotated for any given quadrant, if the relevant toggle
#        is active.
#     4. A sine-wave is applied to one or more channels (see `TIME_SCALE` for the speed of the sine
#        wave).
#     5. If a particular pad is pressed, the color is set to white.
#
# TODO: Input handling seems to interfere with frame rendering, as our FPS seems to "jump" to
# TODO: insane values when a button is pressed.
#
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

SurfaceMaster.init!
device = SurfaceMaster::Launchpad::Device.new

# Light up the corners of the "real" grid, the first four buttons of the CC row, and the corners of
# the virtual grid:
# device[[0, 0]] = [0x01, 0x02, 0x03]
# device[[1, 0]] = [0x01, 0x02, 0x03]
# device[[2, 0]] = [0x01, 0x02, 0x03]
# device[[3, 0]] = [0x01, 0x02, 0x03]

# device[[0, 1]] = [0x01, 0x02, 0x03]
# device[[7, 1]] = [0x01, 0x02, 0x03]
# device[[8, 1]] = [0x01, 0x02, 0x03]

# device[[0, 8]] = [0x01, 0x02, 0x03]
# device[[7, 8]] = [0x01, 0x02, 0x03]
# device[[8, 8]] = [0x01, 0x02, 0x03]

# device.commit!

at_exit do
  (0..8).each do |x|
    (0..8).each do |y|
      device[[x, y]] = [0x00, 0x00, 0x00]
    end
  end
  device.commit!
end

INCR = 17

while results = (device.read rescue nil)
  next if results.empty?
  results.each do |result|
    next unless result.event == :down
    coord = [result.x, result.y]
    cur_color = device[coord]
    cur_color[2] += INCR
    if cur_color[2] >= 0x3F
      cur_color[1] += INCR
      cur_color[2] -= 0x3F
    end
    if cur_color[1] >= 0x3F
      cur_color[0] += INCR
      cur_color[1] -= 0x3F
    end
    cur_color[0] -= 0x3F if cur_color[0] >= 0x3F
    puts results.map(&:to_s).join(", ")
    puts cur_color.inspect

    device[coord] = cur_color
  end
  device.commit!
end
