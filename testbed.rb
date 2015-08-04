#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# interaction = Launchpad::Interaction.new(device_name: "Launchpad MK2")
# interaction.response_to(:grid, :down) do |_interaction, action|
#   puts action.inspect
# end
# # interaction.response_to(:mixer, :down) do |interaction, action|
# #   interaction.stop
# # end
# interaction.start



device = Launchpad::Device.new(device_name: "Launchpad MK2")
output = device.instance_variable_get(:@output)

# "Each element has a brightness value from 00h – 3Fh (0 – 63), where 0 is off and 3Fh is full brightness."
def set_color(output, led, r, g, b)
  # color = (r << 7) | (g << 6) | (b << 3)
  # puts "%02x" % color

  x = output.write_sysex([
    0xF0,
    # Manufacturer/Device/Command:
    0x00,
    0x20,
    0x29,
    0x02,
    0x18,
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

  if x != 0
    puts x
  else
    printf "."
  end
end

(0..7).each do |x|
  (0..7).each do |y|
    note = (y * 10) + x + 11
    set_color(output, note, 0x00, x + 0x10, y + 0x10)
    sleep 0.05
  end
end

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
