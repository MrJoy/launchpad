#!/usr/bin/env ruby
fname = ARGV.shift
raise "Must specify filename." unless fname
outname = fname.gsub(/\.raw/, ".txt")

File.write(outname, File.read(fname).bytes.map { |x| "0x%02X" % x }.join(", "))
