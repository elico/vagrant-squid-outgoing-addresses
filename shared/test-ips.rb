#!/usr/bin/env ruby

require 'open3'

lower = ARGV[0]
higher = ARGV[1]

lines = []


lines << "eliezer  1" 

("#{lower}".."#{higher}").each do |uid|
  cmd = "curl -s -x http://user#{uid}:1234@127.0.0.1:3128 http://192.168.10.80/ip.php"
  stdout, stderr, status = Open3.capture3(cmd)
  puts "user#{uid} => #{stdout}" if stdout.size >0
  puts stderr if stderr.size >0
 end
