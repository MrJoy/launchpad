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
interaction.response_to(:pad, :up, button: 1..4) do |_inter, action|
  puts "LEFT COLUMN PAD UP: #{action.inspect}"
end
interaction.response_to(:pad, :up, button: 5..8, bank: 4, exclusive: true) do |_inter, action|
  puts "SECOND-FROM-LEFT COLUMN PAD UP: #{action.inspect}"
end

interaction.response_to(:vknob, :update) do |_inter, action|
  puts "ANY KNOB, ANY BANK (EXCEPT 2) TURNED: #{action.inspect}"
end
interaction.response_to(:vknob, :update, vknob: 3) do |_inter, action|
  puts "KNOB 3, ANY BANK (EXCEPT 2) TURNED: #{action.inspect}"
end
interaction.response_to(:vknob, :update, bank: 2, exclusive: true) do |_inter, action|
  puts "ANY KNOB, BANK 2 TURNED: #{action.inspect}"
end
interaction.response_to(:vknob, :update, bank: 4, vknob: 1) do |_inter, action|
  puts "KNOB 1, BANK 4 TURNED: #{action.inspect}"
end

interaction.response_to(:accelerometer, :tilt) do |_inter, action|
  puts "ANY AXIS TILT: #{action.inspect}"
end
interaction.response_to(:accelerometer, :tilt, axis: :x) do |_inter, action|
  puts "X-AXIS TILT: #{action.inspect}"
end

interaction.response_to(:vknobs, :down) do |_inter, action|
  puts "ANY VKNOB SELECTOR DOWN: #{action.inspect}"
end
interaction.response_to(:vknobs, :down, index: 2) do |_inter, action|
  puts "VKNOB 2 SELECTOR DOWN: #{action.inspect}"
end

interaction.response_to(:banks, :down) do |_inter, action|
  puts "ANY BANK SELECTOR DOWN: #{action.inspect}"
end
interaction.response_to(:banks, :down, index: 3) do |_inter, action|
  puts "BANK 3 SELECTOR DOWN: #{action.inspect}"
end

interaction.response_to(:shoulder, :down) do |_inter, action|
  puts "ANY SHOULDER DOWN: #{action.inspect}"
end
interaction.response_to(:shoulder, :up) do |_inter, action|
  puts "ANY SHOULDER UP: #{action.inspect}"
end
interaction.response_to(:shoulder, :down, button: :left) do |_inter, action|
  puts "LEFT SHOULDER DOWN: #{action.inspect}"
end
interaction.response_to(:shoulder, :up, button: :left) do |_inter, action|
  puts "LEFT SHOULDER UP: #{action.inspect}"
end

interaction.start
