#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

class Fixnum
  def to_hex; "%02X" % self; end
end

CONTROLS    = { 0x90 => { 0x00 => { type: :pad,           action: :down,    bank: 1 },
                          0x01 => { type: :pad,           action: :down,    bank: 2 },
                          0x02 => { type: :pad,           action: :down,    bank: 3 },
                          0x03 => { type: :pad,           action: :down,    bank: 4 },
                          0x0F => { type: :shoulder,      action: :down } },
                0x80 => { 0x00 => { type: :pad,           action: :up,      bank: 1 },
                          0x01 => { type: :pad,           action: :up,      bank: 2 },
                          0x02 => { type: :pad,           action: :up,      bank: 3 },
                          0x03 => { type: :pad,           action: :up,      bank: 4 },
                          0x0F => { type: :shoulder,      action: :up } },
                0xB0 => { 0x00 => { type: :knob,          action: :update,  vknob: 1 },
                          0x01 => { type: :knob,          action: :update,  vknob: 2 },
                          0x02 => { type: :knob,          action: :update,  vknob: 3 },
                          0x03 => { type: :knob,          action: :update,  vknob: 4 },
                          0x0C => { type: :accelerometer, action: :tilt,    axis: :x },
                          0x0D => { type: :accelerometer, action: :tilt,    axis: :y },
                          0x0F => { type: :control,       action: :switch } } }
SHOULDERS   = { 0x03 => { button: :left },
                0x04 => { button: :right } }
COLLECTIONS = { 0x01 => { collection: :banks },
                0x02 => { collection: :vknobs } }

def debug(msg)
  STDERR.puts "DEBUG: #{msg}"
end

def fmt_message(message)
  message[:raw][:message].map(&:to_hex).join(' ')
end

def decode_shoulder(note, _velocity); SHOULDERS[note]; end
def decode_pad(note, _velocity); { button: note }; end
def decode_knob(note, velocity); { bank: note + 1, value: velocity }; end

def decode_control(note, velocity)
  tmp         = COLLECTIONS[note]
  tmp[:index] = velocity
  tmp
end

def decode_message(message)
  raw_type, note, velocity, _ = message[:raw][:message]
  raw_type_high               = raw_type & 0xF0
  raw_type_low                = raw_type & 0x0F
  meta                        = CONTROLS[raw_type_high][raw_type_low]
  case meta[:type]
  when :shoulder then meta.merge!(decode_shoulder(note, velocity))
  when :pad then      meta.merge!(decode_pad(note, velocity))
  when :knob then     meta.merge!(decode_knob(note, velocity))
  when :control then  meta.merge!(decode_control(note, velocity))
  end

  meta
end

device = Orbit::Device.new
loop do
  inputs = device.read_pending_actions
  inputs.each do |input|
    puts decode_message(input).inspect
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
