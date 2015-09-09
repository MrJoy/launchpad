#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

SurfaceMaster.init!
interaction = SurfaceMaster::Orbit::Interaction.new
interaction.response_to(:pad, :down) do |_inter, action|
  puts "PAD DOWN: #{action.inspect}"
end
interaction.response_to(:pad, :up) do |_inter, action|
  puts "PAD UP: #{action.inspect}"
end
interaction.response_to(:vknob, :update) do |_inter, action|
  puts "KNOB TURNED: #{action.inspect}"
end
interaction.response_to(:accelerometer, :tilt) do |_inter, action|
  puts "TILT: #{action.inspect}"
end
interaction.response_to(:vknobs, :down) do |_inter, action|
  puts "VKNOB SWITCH: #{action.inspect}"
end
interaction.response_to(:banks, :down) do |_inter, action|
  puts "BANK SWITCH: #{action.inspect}"
end
interaction.response_to(:shoulder, :down) do |_inter, action|
  puts "SHOULDER DOWN: #{action.inspect}"
end
interaction.response_to(:shoulder, :up) do |_inter, action|
  puts "SHOULDER UP: #{action.inspect}"
end

interaction.start
