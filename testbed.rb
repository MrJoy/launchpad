#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

device = Launchpad::Device.new(device_name: "Launchpad MK2")
output = device.instance_variable_get(:@output)
output.write([
  { message: [
      # SysEx Start:
      0xF0,
      # Manufacturer/Device/Command:
      0x00,
      0x20,
      0x29,
    ],
    # ].map { |n| Bignum.new(n) },
    timestamp: 0 },
  { message: [
      0x02,
      0x18,
      0x0A,
      # LED:
      0x68, # Up arrow.
    ],
    # ].map { |n| Bignum.new(n) },
    timestamp: 0 },
  { message: [
      # Red, Green, Blue:
      0xFF,
      0x00,
      0x00,
      # SysEx End:
      0xF7,
    ],
    # ].map { |n| Bignum.new(n) },
    timestamp: 0 },
])

# F0h 00h 20h 29h 02h 18h 0Ah <LED>, <Red> <Green> <Blue> F7h

puts device.inspect


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
