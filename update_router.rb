#! /usr/bin/env ruby

require 'netaddr'

# -------------------------------------------------------------------
# Merge IP ranges
# -------------------------------------------------------------------
ip_ranges = Dir.glob("#{__dir__}/data/ip_ranges/*.txt").map { |f| File.read(f).split("\n") }.flatten
ip_ranges.concat File.read("#{__dir__}/data/hosts.txt").split("\n").map { |h| h.split(' ')[0] }
loop do
  length    = ip_ranges.length
  ip_ranges = NetAddr.merge ip_ranges
  break if ip_ranges.length == length
end

# -------------------------------------------------------------------
# Store IP ranges
# -------------------------------------------------------------------
File.open("#{__dir__}/router/router.txt", 'w') do |f|
  f.write "/ip route remove [/ip route find gateway=pptp-out1 static=no]\n"
  ip_ranges.each do |i|
    f.write "/ip route add dst-address=#{i} gateway=pptp-out1\n"
  end
end
