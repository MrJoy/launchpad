#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "control_center"

# class Fixnum
#   def to_hex; "%02X" % self; end
# end

# def debug(msg)
#   STDERR.puts "DEBUG: #{msg}"
# end

# def fmt_message(message)
#   message[:raw][:message].map(&:to_hex).join(' ')
# end

ControlCenter.init!
device = ControlCenter::Orbit::Device.new
loop do
  inputs = device.read
  inputs.each do |input|
    puts input.inspect
  end
end

# interaction = ControlCenter::Launchpad::Interaction.new
# interaction.response_to(:grid) do |inter, action|
#   x = action[:x]
#   y = action[:y]
#   PRESSED[x][y] = (action[:state] == :down)
#   value         = base_color(x, y) || WHITE
#   value[:grid]  = [x, y]
#   inter.device.change(value)
# end

# interaction.device.change({ red: 0x03, green: 0x00, blue: 0x00, cc: :mixer })
# interaction.device.changes(%i(scene1 scene2 scene3 scene4).map { |cc| { red: 0x03, green: 0x03, blue: 0x03, cc: cc } })

# init_board(interaction)
# input_thread = Thread.new do
#   interaction.start
# end
# animation_thread = Thread.new do
#   loop do
#     begin
#       NOW[0] = Time.now.to_f
#       init_board(interaction)
#     rescue Exception => e
#       puts e.inspect
#       puts e.backtrace.join("\n")
#     end
#     sleep 0.01
#   end
# end

# input_thread.join
# animation_thread.terminate
# goodbye(interaction)
