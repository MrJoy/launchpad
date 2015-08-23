#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

def init_board(interaction)
  (0..7).each do |x|
    (0..7).each do |y|
      interaction.device.change_grid(x, y, 0x00, x + 0x10, y + 0x10)
      sleep 0.002
    end
  end
end

def goodbye(interaction)
  (0..64).step(4).each do |i|
    ii = 64 - i
    (0..7).each do |x|
      (0..7).each do |y|
        interaction.device.change_grid(x, y, ii, 0x00, ii)
        sleep 0.002
      end
    end
  end
end

interaction = Launchpad::Interaction.new
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  if action[:state] == :down
    r, g, b = 0x3F, 0x00, 0x00
  else
    r, g, b = 0x00, x + 0x10, y + 0x10
  end
  inter.device.change_grid(x, y, r, g, b)
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "STAHP!"
  goodbye(interaction)
  interaction.stop
end
init_board(interaction)
interaction.start
