#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# "Each element has a brightness value from 00h – 3Fh (0 – 63), where 0 is off and 3Fh is full brightness."
def set_color(device, x, y, r, g, b)
  output = device.instance_variable_get(:@output)

  led = (y * 10) + x + 11
  x   = output.write_sysex([
    # SysEx Begin:
    0xF0,
    # Manufacturer/Device:
    0x00,
    0x20,
    0x29,
    0x02,
    0x18,
    # Command:
    0x0B,
    # LED:
    led,
    # Red, Green, Blue:
    r,
    g,
    b,
    # SysEx End:
    0xF7,
  ])

  puts "ERROR: #{x}" if x != 0
  x
end

def init_board(interaction)
  (0..7).each do |x|
    (0..7).each do |y|
      set_color(interaction.device, x, y, 0x00, x + 0x10, y + 0x10)
      sleep 0.001
    end
  end
end

def goodbye(interaction)
  (0..64).step(4).each do |i|
    ii = 64 - i
    (0..7).each do |x|
      (0..7).each do |y|
        set_color(interaction.device, x, y, ii, 0x00, ii)
        sleep 0.001
      end
    end
  end
end

interaction = Launchpad::Interaction.new(device_name: "Launchpad MK2")
interaction.response_to(:grid) do |inter, action|
  x = action[:x]
  y = action[:y]
  if action[:state] == :down
    r, g, b = 0x3F, 0x00, 0x00
  else
    r, g, b = 0x00, x + 0x10, y + 0x10
  end
  set_color(inter.device, x, y, r, g, b)
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "STAHP!"
  goodbye(interaction)
  interaction.stop
end
init_board(interaction)
interaction.start
