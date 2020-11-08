#!/usr/bin/env ruby

ip_addresses_map = {}

counter=1

`ip -o a list|grep 'inet 192.168.10' |awk '{ print $4}'`.lines.each do |ip|
  ip=ip.chomp
  next if !ip.end_with?("/32")
  ip_addresses_map[ip.gsub("/32", "").chomp] = "ip#{counter}"
  counter = counter + 1 
end

def dumpAddresses(ip_map)
  ip_map.each_key do |key|
    acl_name = ip_map[key]
    puts "acl #{ip_map[key]} note ip #{acl_name.match(/([0-9]+)/)[1]}"
    puts("tcp_outgoing_address #{key} #{acl_name}")
  end
end

dumpAddresses(ip_addresses_map)
