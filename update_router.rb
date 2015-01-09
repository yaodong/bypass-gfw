#! /usr/bin/env ruby

require 'json'

vpn_gateway = 'pptp-out1'
ip_ranges   = JSON.parse File.read("#{__dir__}/data/ip_ranges.json")

rules = ['/ip route remove [/ip route find gateway=pptp-out1 comment=gfw-butter]']
rules.concat ip_ranges.map{ |i| "/ip route add dst-address=#{i} gateway=#{vpn_gateway} comment=gfw-butter" }
File.write "#{__dir__}/router/router.txt", rules.join("\n")
