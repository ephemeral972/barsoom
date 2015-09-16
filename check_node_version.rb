#!/user/bin/env ruby

require 'pp'
require 'json'

node_list = []
version_hash = {}
dup_arr = []


# check nmctl command works
chk_nmctl = `nmctl ps 2>&1`
nmctl_status = $?.success?

if !nmctl_status
  puts "nmctl command failed with message: \n#{chk_nmctl}"
  exit
else
  # open subprocess and read ouput of nmctl into hash
  cmd_nmctl = open("|nmctl nodes")
  cmd_nmctl.read().each_line{
    |line| build_info  = line.split
    version_hash [build_info[2]] = build_info[3]
  }

  # remove null and ip-> version hash key value
  version_hash.delete_if{|k,v| v =~ /Version(.*)/ ||  v.nil?}

  # check if build version is same for all nodess
  node_list = version_hash.collect{|k,v| v}
  if node_list.uniq.length == 1
    puts "Builds match, build version is #{node_list[0]}"
  else
    puts "Builds differ"
    dup_arr  =  node_list.group_by{|e| e}.keep_if{|_,e| e.length > 1}
    pp  dup_arr
    pp "#{dup_arr.map{|k,v| {k => v.length}}}"
    puts "complete build list"
    pp version_hash
  end
end
