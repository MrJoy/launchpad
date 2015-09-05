#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

device = Orbit::Device.new
TYPES = {
  0x80 => "  up",
  0x90 => "down",
}
loop do
  inputs = device.read_pending_actions
  inputs.each do |input|
    (type, note, velocity) = input[:raw][:message]
    if TYPES[type & 0xF0]
      channel = type & 0x0F
      type    = type & 0xF0
    end
    case type
    when 0xBF
      case note
      when 1
        # Switching banks...
        puts "Switching bank:  #{velocity}"
      when 2
        puts "Switching VKnob: #{velocity}"
      else
        puts "WAT:             #{input[:raw][:message].inspect}"
      end
    when 0x90
      puts "Down:              #{[channel, note].map { |x| '%02x' % x }.join(' ')}"
    when 0x80
      puts "Up:                #{[channel, note].map { |x| '%02x' % x }.join(' ')}"
    else
      puts "WAT:               #{input[:raw][:message].inspect}"
    end
  end
end

# interaction = Launchpad::Interaction.new
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
