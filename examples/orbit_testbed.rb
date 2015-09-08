#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

# Monkey-patching to make debugging easier.
class Fixnum
  def to_hex; "%02X" % self; end
end

SurfaceMaster.init!
device = SurfaceMaster::Orbit::Device.new
loop do
  device.read.each do |input|
    puts input.inspect
  end
  sleep 0.1
end
