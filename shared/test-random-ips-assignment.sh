#!/usr/bin/env bash

ruby /vagrant/generate-user-to-ip.rb "/etc/squid/user-to-ip.txt" 01 80

echo "will wait 5 seconds.."
for i in {1..6}
do
  echo -n "${i}.. "
  sleep 1
done

echo "testing.."
ruby /vagrant/test-ips.rb 01 15

echo "Testing Random IP addresses assignment"
for i in {1..4}
do
  ruby /vagrant/generate-user-to-ip.rb "/etc/squid/user-to-ip.txt" 01 80 1
  echo "Iter: ${i}"
  echo "Sleeping 6 seconds"
  sleep 6
  echo "Slept 6 secoonds"
  ruby /vagrant/test-ips.rb 01 15
done

