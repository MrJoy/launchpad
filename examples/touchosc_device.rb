#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

SurfaceMaster.init!
device = SurfaceMaster::TouchOSC::Device.new do |input|
  result = { state: input[:state] }
  case input[:code]
  when 0xB0
    result[:type]     = :slider
    result[:index]    = input[:note]
    result[:position] = input[:velocity]
    result[:state]    = :update
  else
    result[:type]     = :unknown
  end
  result
end

input_thread = Thread.new do
  loop do
    begin
      x = STDIN.gets
      note, velocity = x.split(/ /, 2).map(&:to_i)
      device.write([{ message: [0xB0, note, velocity], timestamp: 0 }])
    rescue Exception => e
      puts e.inspect
      puts e.backtrace.join("\n")
    end
  end
end

loop do
  device.read.each do |input|
    puts input.inspect
  end
  sleep 0.1
end
input_thread.join
