#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "launchpad"

# "Each element has a brightness value from 00h – 3Fh (0 – 63), where 0 is off and 3Fh is full brightness."
def set_color(device, x, y, r, g, b)
  output = device.instance_variable_get(:@output)

  led = (y * 10) + x + 11
  x   = output.write_sysex([
    # SysEx Begin:
    0xF0,
    # Manufacturer/Device:
    0x00,
    0x20,
    0x29,
    0x02,
    0x18,
    # Command:
    0x0B,
    # LED:
    led,
    # Red, Green, Blue:
    r,
    g,
    b,
    # SysEx End:
    0xF7,
  ])

  puts "ERROR: #{x}" if x != 0
  x
end

def goodbye(interaction)
  (0..7).each do |x|
    (0..7).each do |y|
      set_color(interaction.device, x, y, 0x00, 0x00, 0x00)
      sleep 0.001
    end
  end
end

def bar(interaction, x, val, r, g, b)
  (0..val).each do |y|
    set_color(interaction.device, x, y, r, g, b)
  end
  ((val+1)..7).each do |y|
    set_color(interaction.device, x, y, 0x00, 0x00, 0x00)
  end
end

interaction = Launchpad::Interaction.new(device_name: "Launchpad MK2")
monitor = Thread.new do
  loop do
    fields      = `iostat -c 2 disk0`.split(/\n/).last.strip.split(/\s+/)
    cpu_pct     = 100 - fields[-4].to_i
    cpu_usage   = ((cpu_pct / 100.0) * 8.0).round.to_i

    disk_pct    = (fields[2].to_f / 750.0) * 100.0
    disk_usage  = ((disk_pct / 100.0) * 8.0).round.to_i

    puts "io=#{disk_pct}%, cpu=#{cpu_pct}%"

    bar(interaction, 0, cpu_usage, 0x3F, 0x00, 0x00)
    bar(interaction, 1, disk_usage, 0x00, 0x3F, 0x00)
  end
end

interaction.response_to(:mixer, :down) do |_interaction, action|
  puts "Shutting down"
  begin
    monitor.kill
    goodbye(interaction)
    interaction.stop
  rescue Exception => e
    puts e.inspect
  end
end
interaction.start
