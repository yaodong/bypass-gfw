#! /usr/bin/env ruby

require 'netaddr'
require 'json'

vpn_gateway = 'pptp-out1'

# -------------------------------------------------------------------
# Merge IP ranges
# -------------------------------------------------------------------
ip_ranges = Dir.glob("#{__dir__}/data/ip_ranges/*.json").map { |f| JSON.parse File.read(f) }.flatten
ip_ranges.concat JSON.parse(File.read("#{__dir__}/data/domains.json")).values
loop do
  length    = ip_ranges.length
  ip_ranges = NetAddr.merge ip_ranges
  break if ip_ranges.length == length
end

# -------------------------------------------------------------------
# Store IP ranges
# -------------------------------------------------------------------
rules = ['/ip route remove [/ip route find gateway=pptp-out1 static=no]']
rules.concat ip_ranges.map{ |i| "/ip route add dst-address=#{i} gateway=#{vpn_gateway}" }
File.write "#{__dir__}/router/router.txt", rules.join("\n")
