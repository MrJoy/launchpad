#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

device = SurfaceMaster::Orbit::Device.new
loop do
  device.read.each do |input|
    puts input.inspect
  end
  sleep 0.1
end
