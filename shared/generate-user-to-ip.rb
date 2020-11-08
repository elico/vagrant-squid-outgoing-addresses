#!/usr/bin/env ruby

require 'open3'

map_file = ARGV[0]
lower = ARGV[1]
higher = ARGV[2]

random = ARGV[3]

lines = []

lines << "eliezer  1" 

("#{lower}".."#{higher}").each do |uid|
  lines << "user#{uid}  #{if random != "1"; uid.to_i;else; rand(lower.to_i..higher.to_i )end }"
end

File.write(map_file, lines.join("\n"))
