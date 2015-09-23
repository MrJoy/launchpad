#!/usr/bin/env ruby
# Cycle Numark Orbit colors through a wheel.
#
# IMPORTANT: Set `MODE` below to `:wired`, or `:wireless`, as appropriate to
# IMPORTANT: how your Numark Orbit is connected!
#
# NOTE: If the lights do not blank out when this starts, your device is in a
# NOTE: bad state.  Push a config to it from the Numark Orbit Editor.  If that
# NOTE: doesn't work, power-cycle it and try again!
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

device = SurfaceMaster::Orbit::Device.new
# The device seems to be notably less able to accept updates over wireless, and
# perhaps because CoreMIDI has no backpressure, we can easily wind up hosed.
# Before settling on new values here, run the process for *several full minutes*
# and make sure the device continues accepting updates at the end!
#
# TODO: More thorough stress testing.
#
# TODO: Can we determine if the connection is wired/wireless automatically?
#
# TODO: Can we safely get input simultaneously?
MODE      = :wired

CONFIGS   = { wireless: { delay: 0.75, offset: 0x03, use_read: true,  read_delay: 0.1 },
              wired:    { delay: 0.1,  offset: 0x01, use_read: false, read_delay: 0 } }
MAPPINGS  =  [0x03, 0x01, 0x70,

              0x00, 0x00, 0x00,
              0x00, 0x04, 0x04,
              0x00, 0x08, 0x08,
              0x00, 0x0C, 0x0C,
              0x00, 0x01, 0x01,
              0x00, 0x05, 0x05,
              0x00, 0x09, 0x09,
              0x00, 0x0D, 0x0D,
              0x00, 0x02, 0x02,
              0x00, 0x06, 0x06,
              0x00, 0x0A, 0x0A,
              0x00, 0x0E, 0x0E,
              0x00, 0x03, 0x03,
              0x00, 0x07, 0x07,
              0x00, 0x0B, 0x0B,
              0x00, 0x0F, 0x0F,
              0x01, 0x00, 0x10,
              0x01, 0x04, 0x14,
              0x01, 0x08, 0x18,
              0x01, 0x0C, 0x1C,
              0x01, 0x01, 0x11,
              0x01, 0x05, 0x15,
              0x01, 0x09, 0x19,
              0x01, 0x0D, 0x1D,
              0x01, 0x02, 0x12,
              0x01, 0x06, 0x16,
              0x01, 0x0A, 0x1A,
              0x01, 0x0E, 0x1E,
              0x01, 0x03, 0x13,
              0x01, 0x07, 0x17,
              0x01, 0x0B, 0x1B,
              0x01, 0x0F, 0x1F,
              0x02, 0x00, 0x20,
              0x02, 0x04, 0x24,
              0x02, 0x08, 0x28,
              0x02, 0x0C, 0x2C,
              0x02, 0x01, 0x21,
              0x02, 0x05, 0x25,
              0x02, 0x09, 0x29,
              0x02, 0x0D, 0x2D,
              0x02, 0x02, 0x22,
              0x02, 0x06, 0x26,
              0x02, 0x0A, 0x2A,
              0x02, 0x0E, 0x2E,
              0x02, 0x03, 0x23,
              0x02, 0x07, 0x27,
              0x02, 0x0B, 0x2B,
              0x02, 0x0F, 0x2F,
              0x03, 0x00, 0x30,
              0x03, 0x04, 0x34,
              0x03, 0x08, 0x38,
              0x03, 0x0C, 0x3C,
              0x03, 0x01, 0x31,
              0x03, 0x05, 0x35,
              0x03, 0x09, 0x39,
              0x03, 0x0D, 0x3D,
              0x03, 0x02, 0x32,
              0x03, 0x06, 0x36,
              0x03, 0x0A, 0x3A,
              0x03, 0x0E, 0x3E,
              0x03, 0x03, 0x33,
              0x03, 0x07, 0x37,
              0x03, 0x0B, 0x3B,
              0x03, 0x0F, 0x3F,

              0x00, 0x00, 0x01,
              0x00, 0x02, 0x00,
              0x03, 0x00, 0x00,
              0x01, 0x01, 0x01,
              0x02, 0x01, 0x03,
              0x01, 0x00, 0x02,
              0x01, 0x02, 0x02,
              0x02, 0x03, 0x02,
              0x00, 0x03, 0x01,
              0x03, 0x02, 0x03,
              0x03, 0x03, 0x0C,
              0x00, 0x0D, 0x00,
              0x0C, 0x00, 0x0D,
              0x00, 0x0C, 0x00,
              0x0D, 0x00, 0x0C,
              0x00, 0x0D, 0x00]
READ_STATE = [0x01, 0x00, 0x00]

delay       = CONFIGS[MODE][:delay]
offset      = CONFIGS[MODE][:offset]
use_read    = CONFIGS[MODE][:use_read]
read_delay  = CONFIGS[MODE][:read_delay]

sleep delay
puts "Starting..."
indices = (0..63).map { |n| 5 + (3 * n) }
loop do
  indices.each do |i|
    MAPPINGS[i] = (MAPPINGS[i] + offset) % 0x3F
  end
  device.send(:sysex!, *MAPPINGS)
  if use_read
    sleep read_delay
    device.send(:sysex!, *READ_STATE)
  end
  printf "."
  sleep delay
end
