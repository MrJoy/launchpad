#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# Flash:    F0h 00h 20h 29h 02h 18h 23h <LED> <Colour> F7h
# Pulse:    F0h 00h 20h 29h 02h 18h 28h <LED> <Colour> F7h
# Set all:  F0h 00h 20h 29h 02h 18h 0Eh <Colour> F7h
# Set row:  F0h 00h 20h 29h 02h 18h 0Dh <Row> <Colour> F7h
# Set col:  F0h 00h 20h 29h 02h 18h 0Ch <Column> <Colour> F7h

# By default, Launchpad MK2 will flash and pulse at 120 BPM. This can be altered by sending Launchpad MK2 F8h (248) messages (MIDI clock), which should be sent at a rate of 24 per beat. To set a tempo of 100 BPM, 2400 MIDI clock messages should be sent each minute, or with a time interval of 25ms.
# Launchpad MK2 supports tempos between 40 and 240 BPM.
QUADRANTS = [
  [{ red: 0x3F, green: 0x00, blue: 0x00 }, { red: 0x00, green: 0x3F, blue: 0x00 }],
  [{ red: 0x00, green: 0x00, blue: 0x3F }, { red: 0x3F, green: 0x3F, blue: 0x00 }],
]
SCALE = 2

def base_color(x, y)
  quad_x = x / 4
  quad_y = 1 - (y / 4)
  quad = QUADRANTS[quad_y][quad_x]
  tmp = { red: 0x00 + quad[:red], green: (x * SCALE) + quad[:green], blue: (y * SCALE) + quad[:blue] }
  tmp.keys.each do |key|
    tmp[key] = 0x3F if tmp[key] > 0x3F
  end
  tmp
end

GRID = (0..7).map { |x| (0..7).map { |y| { grid: [x, y] } } }.flatten

def init_board(interaction)
  values = GRID.map { |value| value.merge(base_color(*value[:grid])) }
  interaction.device.changes(values)
end

def set_grid_rgb(interaction, red:, green:, blue: )
  values = GRID.map do |value|
    value.merge(red: red, green: green, blue: blue)
  end
  interaction.device.changes(values)
end

def goodbye(interaction)
  (0..63).step(2).each do |i|
    ii = (63 - i) - 1
    set_grid_rgb(interaction, red: ii, green: 0x00, blue: ii)
    sleep 0.01
  end
end

interaction = Launchpad::Interaction.new
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  if action[:state] == :down
    value = { red: 0x3F, green: 0x3F, blue: 0x3F }
  else
    value = base_color(x, y)
  end
  value[:grid] = [x, y]
  inter.device.change(value)
end

def flip_quad!(inter, cc, quad_x, quad_y)
  quad                      = QUADRANTS[quad_y][quad_x]
  QUADRANTS[quad_y][quad_x] = { red:    0x3F - quad[:red],
                                green:  0x3F - quad[:green],
                                blue:   0x3F - quad[:blue] }
  FLIPPED[quad_y][quad_x]   = !FLIPPED[quad_y][quad_x]
  if FLIPPED[quad_y][quad_x]
    color = { red: 0x1F, green: 0x1F, blue: 0x1F }
  else
    color = { red: 0x03, green: 0x03, blue: 0x03 }
  end
  inter.device.change(color.merge(cc: cc))
  init_board(inter)
end

CC = %i(up down left right session user1 user2 scene1 scene2 scene3 scene4 scene5 scene6 scene7 scene8)
FLIPPED = [[false, false], [false, false]]
interaction.response_to(:scene1, :down) do |inter, action|
  flip_quad!(inter, action[:type], 0, 0)
end
interaction.response_to(:scene2, :down) do |inter, action|
  flip_quad!(inter, action[:type], 1, 0)
end
interaction.response_to(:scene3, :down) do |inter, action|
  flip_quad!(inter, action[:type], 0, 1)
end
interaction.response_to(:scene4, :down) do |inter, action|
  flip_quad!(inter, action[:type], 1, 1)
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  interaction.stop
end
interaction.device.change({ red: 0x03, green: 0x00, blue: 0x00, cc: :mixer })
interaction.device.changes(%i(scene1 scene2 scene3 scene4).map { |cc| { red: 0x03, green: 0x02, blue: 0x03, cc: cc } })

init_board(interaction)
input_thread = Thread.new do
  interaction.start
end
animation_thread = Thread.new do
  loop do
    (0..1).each do |quad_x|
      (0..1).each do |quad_y|
        init_board(interaction)
        sleep 0.05
      end
    end
  end
end

input_thread.join
animation_thread.terminate
goodbye(interaction)
