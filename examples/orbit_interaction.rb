#!/usr/bin/env ruby
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

SurfaceMaster.init!
interaction = SurfaceMaster::Orbit::Interaction.new
interaction.response_to(:grid, :down) do |_inter, action|
  puts "PAD DOWN: #{action.inspect}"
end
interaction.response_to(:grid, :up) do |_inter, action|
  puts "PAD UP: #{action.inspect}"
end
interaction.response_to(:grid, :up, x: 0, y: 0..3) do |_inter, action|
  puts "LEFT COLUMN PAD UP: #{action.inspect}"
end
interaction.response_to(:grid, :up, x: 1, y: 0..3, bank: 3, exclusive: true) do |_inter, action|
  puts "SECOND-FROM-LEFT COLUMN, LAST BANK, PAD UP: #{action.inspect}"
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
interaction.response_to(:vknob, :update, bank: 1, vknob: 1) do |_inter, action|
  puts "KNOB 1, BANK 1 TURNED: #{action.inspect}"
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
interaction.response_to(:vknobs, :down, button: 2) do |_inter, action|
  puts "VKNOB 2 SELECTOR DOWN: #{action.inspect}"
end

interaction.response_to(:banks, :down) do |_inter, action|
  puts "ANY BANK SELECTOR DOWN: #{action.inspect}"
end
interaction.response_to(:banks, :down, button: 3) do |_inter, action|
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

puts "Starting input loop..."
interaction.start
