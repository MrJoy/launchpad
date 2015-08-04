#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# "Each element has a brightness value from 00h – 3Fh (0 – 63), where 0 is off and 3Fh is full brightness."
def set_color(device, x, y, r, g, b)
  output = device.instance_variable_get(:@output)

  puts "set_color(..., #{x}, #{y}, #{r}, #{g}, #{b})"
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
      sleep 0.01
    end
  end
end

interaction = Launchpad::Interaction.new(device_name: "Launchpad MK2")
interaction.response_to(:grid) do |interaction, action|
  puts action.inspect
  if action[:state] == :down
    set_color(interaction.device, action[:x], action[:y], 0x3F, 0x00, 0x00)
  else
    set_color(interaction.device, action[:x], action[:y], 0x00, action[:x] + 0x10, action[:y] + 0x10)
  end
end
interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "STAHP!"
  interaction.stop
end
init_board(interaction)
interaction.start

# note = note - 11
# data[:x] = note % 10
# data[:y] = note / 10

# {:timestamp=>140, :state=>:down, :type=>:grid, :note=>11, :x=>0, :y=>0}
# {:timestamp=>2994, :state=>:down, :type=>:grid, :note=>18, :x=>7, :y=>0}
# {:timestamp=>5002, :state=>:down, :type=>:grid, :note=>81, :x=>0, :y=>7}
# {:timestamp=>6451, :state=>:down, :type=>:grid, :note=>88, :x=>7, :y=>7}



# F0h 00h 20h 29h 02h 18h 0Ah <LED>, <Red> <Green> <Blue> F7h

# puts device.inspect


    # module Launchpad

    #   # Module defining constants for MIDI codes.
    #   module MidiCodes

    #     # Module defining MIDI status codes.
    #     module Status
    #       NIL           = 0x00
    #       OFF           = 0x80
    #       ON            = 0x90
    #       MULTI         = 0x92
    #       CC            = 0xB0
    #     end

    # def output(status, data1, data2)
    #   output_messages([message(status, data1, data2)])
    # def output_messages(messages)
    #   if @output.nil?
    #     logger.error "trying to write to device that's not been initialized for output"
    #     raise NoOutputAllowedError
    #   end
    #   logger.debug "writing messages to launchpad:\n  #{messages.join("\n  ")}" if logger.debug?
    #   @output.write(messages)
    #   nil
    # def velocity(opts)
    #   if opts.is_a?(Hash)
    #     red = brightness(opts[:red] || 0)
    #     green = brightness(opts[:green] || 0)
    #     color = 16 * green + red
    #     flags = case opts[:mode]
    #             when :flashing  then  8
    #             when :buffering then  0
    #             else                  12
    #             end
    #     color + flags
    #   else
    #     opts.to_i + 12
    # def brightness(brightness)
    #   case brightness
    #   when 0, :off            then 0
    #   when 1, :low,     :lo   then 1
    #   when 2, :medium,  :med  then 2
    #   when 3, :high,    :hi   then 3
    # # [<tt>:message</tt>]   an array of
    # #                       MIDI status code,
    # #                       MIDI data 1 (note),
    # #                       MIDI data 2 (velocity)
    # def message(status, data1, data2)
    #   {:message => [status, data1, data2], :timestamp => 0}
