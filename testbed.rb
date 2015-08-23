#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

def base_color(x, y)
  { red: 0x00, green: (x * 2) + 0x10, blue: (y * 2) + 0x10 }
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
    value = { red: 0x3F, green: 0x00, blue: 0x00 }
  else
    value = base_color(x, y)
  end
  value[:grid] = [x, y]
  inter.device.change(value)
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "STAHP!"
  goodbye(interaction)
  interaction.stop
end
init_board(interaction)
interaction.start
