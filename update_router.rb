#! /usr/bin/env ruby

require 'json'
require 'cidr-lite'

vpn_gateway = 'pptp-out1'

# -------------------------------------------------------------------
# Merge IP ranges
# -------------------------------------------------------------------
ip_ranges = Dir.glob("#{__dir__}/data/ip_ranges/*.json").map { |f| JSON.parse File.read(f) }.flatten
ip_ranges.concat JSON.parse(File.read("#{__dir__}/data/domains.json")).values

lite = CIDR::Lite.new
ip_ranges.each {|v| 
	lite.add v
}

# -------------------------------------------------------------------
# Store IP ranges
# -------------------------------------------------------------------
rules = ['/ip route remove [/ip route find gateway=pptp-out1 static=no]']
rules.concat lite.list.map{ |i| "/ip route add dst-address=#{i} gateway=#{vpn_gateway}" }
File.write "#{__dir__}/router/router.txt", rules.join("\n")
