#!/usr/bin/env ruby

require 'open3'

htpasswd_file = ARGV[0]
lower = ARGV[1]
higher = ARGV[2]

def createuser(user, password, htpasswd_file)
  create = ""
  create = "-c" if !File.exists?(htpasswd_file)
  cmd = "/usr/bin/htpasswd #{create} -b #{htpasswd_file} #{user} #{password}"
  stdout, stderr, status = Open3.capture3(cmd)
  if !status.success?
    puts(stdout) if stdout.size >0
    puts(stderr) if stderr.size >0
  end
end


createuser("eliezer", "1234", htpasswd_file)

("#{lower}".."#{higher}").each do |uid|
   createuser("user#{uid}", "1234", htpasswd_file)
end
