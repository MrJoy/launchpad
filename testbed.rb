#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

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
  QUADRANTS[quad_y][quad_x] = { red: 0x3F - quad[:red],
                                green: 0x3F - quad[:green],
                                blue: 0x3F - quad[:blue] }
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
  goodbye(interaction)
  interaction.stop
end
interaction.device.change({ red: 0x03, green: 0x00, blue: 0x00, cc: :mixer })
interaction.device.changes(%i(scene1 scene2 scene3 scene4).map { |cc| { red: 0x03, green: 0x02, blue: 0x03, cc: cc } })

init_board(interaction)
interaction.start
