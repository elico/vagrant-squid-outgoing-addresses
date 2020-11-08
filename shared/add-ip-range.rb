#!/usr/bin/env ruby

require 'open3'

ip = ARGV[0]
ip_prefix = ARGV[1]

lower = ARGV[2]
higher = ARGV[3]

$exist_counter = 0

("#{lower}".."#{higher}").each do |i|
  cmd = "/vagrant/add-ip-by-ipv4-address.sh #{ip} #{ip_prefix}#{i}/32"
  stdout, stderr, status = Open3.capture3(cmd)
  if !status.success?
    puts stdout if stdout.size >0
    case stderr
      when /RTNETLINK answers: File exists/ 
         $exist_counter = $exist_counter +1
         next
      else
        puts(stderr)
         exit 1
      end
  end
end
puts("RTNETLINK answers: File exists * #{$exist_counter}") if $exist_counter >0
