#!/usr/bin/env ruby
# encoding: utf-8

=begin
license note
Copyright (c) 2020, Eliezer Croitoru
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

require "rubygems"
require "open-uri"
require "syslog"

trap "SIGINT" do
  STDERR.puts "STDERR: Exiting"
  exit 130
end

$user_to_ip = {}

$map_file_name = "/etc/squid/user-to-ip.txt"

$map_file_stat = File.stat($map_file_name)

def readMapFile(mapfile)
  lines = File.readlines(mapfile)
  log("Mapfile #{$map_file_name} lines #{lines.size}")
  lines.each do |line|
    if line =~ /^([a-zA-Z\-\_0-9]+)[\t\s]+([0-9]+)/
      $user_to_ip[$1] = $2.to_i
    end
  end
  $map_file_stat = File.stat($map_file_name)
  log("user_to_ip map size #{$user_to_ip.size}")
end

def statsTest(request)
  return if request == nil
  ret = 0
  if request.size > 0
    res = $user_to_ip[request[0]]
    ret = res if res != nil
  end
  return ret
end

def answer(ans)
  log("Answer [ #{ans} ]") if $debug
  puts(ans)
end

def log(msg)
  Syslog.log(Syslog::LOG_ERR, "%s", msg)
  STDERR.puts("STDERR: [ #{msg} ]") if $debug
end

def evalulateConc
  request = gets
  if request && (request.match /^[0-9]+\ /)
    conc(request)
    return true
  else
    noconc(request)
    return false
  end
end

def conc(request)
  return unless request
  request = request.split
  if request.size > 1
    readMapFile($map_file_name) if $map_file_stat.mtime != File.stat($map_file_name).mtime
    log("original request [#{request.join(" ")}].") if $debug
    result = statsTest(request[1..-1])
    answer("#{request[0]} OK ip=#{result}")
  else
    log("original request [had a problem].") if $debug
    puts "ERR"
  end
end

def noconc(request)
  return unless request
  request = request.split
  if request.size > 1
    readMapFile($map_file_name) if $map_file_stat.mtime != File.stat($map_file_name).mtime
    log("Original request [#{request.join(" ")}].") if $debug
    result = statsTest(request)
    answer("OK ip=#{result}")
  else
    log("Original request [had a problem].") if $debug
    puts "ERR"
  end
end

def validr?(request)
  if request.ascii_only? && request.valid_encoding?
    true
  else
    STDERR.puts("errorness line#{request}")
    # sleep 2
    false
  end
end

def main
  Syslog.open("note.rb", Syslog::LOG_PID)
  log("Started with DEBUG => #{$debug}")
  readMapFile($map_file_name)
  c = evalulateConc
  if c
    log("Identified concurrenty support in this session") if $debug
  else
    log("No concurrenty support on this session") if $debug
  end

  if c
    while request = gets
      conc(request) if validr?(request)
    end
  else
    while request = gets
      noconc(request) if validr?(request)
    end
  end
end

$debug = false
$debug = true

STDOUT.sync = true
main
