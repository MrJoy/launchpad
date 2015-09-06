#!/usr/bin/env ruby
fname = ARGV.shift
raise "Must specify filename." unless fname
outname = fname.gsub(/\.raw/, ".txt")

bytes   = File.read(fname).bytes.map { |x| "0x%02X" % x }
output = [bytes.shift(5).join(", ")] # SysEx vendor header...

output << bytes.shift(2).join(", ") # Apparent prefix...
while (row = bytes.shift(3).join(", ")) != ""
  output << row
end

File.write(outname, output.join("\n") + "\n")
