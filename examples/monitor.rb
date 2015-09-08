#!/usr/bin/env ruby
# require "bignum"
require "rubygems"
require "bundler/setup"
Bundler.require(:default, :development)

require "surface_master"

def goodbye(interaction)
  data = []
  (0..7).each do |x|
    (0..7).each do |y|
      data << { x: x, y: y, red: 0x00, green: 0x00, blue: 0x00 }
    end
  end
  interaction.changes(data)
end

def bar(interaction, x, val, r, g, b)
  data = []
  (0..val).each do |y|
    data << { x: x, y: y, red: r, green: g, blue: b }
  end
  ((val + 1)..7).each do |y|
    data << { x: x, y: y, red: 0x00, green: 0x00, blue: 0x00 }
  end
  interaction.changes(data)
end

interaction = SurfaceMaster::Launchpad::Interaction.new
monitor = Thread.new do
  loop do
    fields      = `iostat -c 2 disk0`.split(/\n/).last.strip.split(/\s+/)
    cpu_pct     = 100 - fields[-4].to_i
    cpu_usage   = ((cpu_pct / 100.0) * 8.0).round.to_i

    disk_pct    = (fields[2].to_f / 750.0) * 100.0
    disk_usage  = ((disk_pct / 100.0) * 8.0).round.to_i

    puts "I/O=#{disk_pct}%, CPU=#{cpu_pct}%"

    # TODO: Network in/out...

    # TODO: Make block I/O not be a bar but a fill, with scale indicated by color...

    bar(interaction, 0, cpu_usage, 0x3F, 0x00, 0x00)
    bar(interaction, 1, disk_usage, 0x00, 0x3F, 0x00)
  end
end

interaction.response_to(:mixer, :down) do |_interaction, _action|
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
