#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

class Fixnum
  def to_hex; "%02X" % self; end
end

device = Orbit::Device.new
TYPES = { 0x80 => :up,
          0x90 => :down,
          0xB0 => :controller }
CONTROLS  = { 0x90 => { 0x00 => { type: :pad,           action: :down,    bank: 1 },
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
                        0x0F => { type: :control,       action: :switch } } }
# TODO: With current mapping, accelerometers are ambiguous.  Need to fix that...

def debug(msg)
  STDERR.puts "DEBUG: #{msg}"
end

def fmt_message(message)
  message[:raw][:message].map(&:to_hex).join(' ')
end

def decode_message(message)
  raw_type, note, velocity, _ = message[:raw][:message]
  raw_type_high               = raw_type & 0xF0
  raw_type_low                = raw_type & 0x0F
  meta                        = CONTROLS[raw_type_high][raw_type_low]
  unrecognized                = false
  debug fmt_message(message)
  case meta[:type]
  when :shoulder
    case note
    when 0x03 then meta[:button] = :left
    when 0x04 then meta[:button] = :right
    else           unrecognized = true
    end
  when :pad
    meta[:button] = note
  when :knob
    meta[:bank]   = note + 1
    meta[:value]  = velocity
  when :control
    case note
    when 0x01 then meta[:collection] = :banks
    when 0x02 then meta[:collection] = :vknobs
    else           unrecognized = true
    end
    meta[:index] = velocity
  end

  debug "Unknown message: #{fmt_message(message)}" if unrecognized

  meta
end

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
