#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

def init_board(interaction)
  (0..7).each do |x|
    (0..7).each do |y|
      interaction.device.change({ x: x, y: y }.merge(base_color(x, y)))
    end
  end

  # values = []
  # (0..7).each do |x|
  #   values += (0..7).map { |y| { x: x, y: y }.merge(base_color(x, y)) }
  # end
  # interaction.device.changes(values)
end

def goodbye(interaction)
  (0..64).step(4).each do |i|
    ii = 64 - i
    (0..7).each do |x|
      (0..7).each do |y|
        interaction.device.change(x: x, y: y, red: ii, green: 0x00, blue: ii)
      end
    end
    sleep 0.05
  end
end

interaction = Launchpad::Interaction.new
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  if action[:state] == :down
    color = { red: 0x3F, green: 0x00, blue: 0x00 }
  else
    color = base_color(x, y)
  end
  inter.device.change({ x: x, y: y }.merge(color))
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "STAHP!"
  goodbye(interaction)
  interaction.stop
end
init_board(interaction)
interaction.start
