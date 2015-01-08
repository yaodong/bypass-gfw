#! /usr/bin/env ruby

require 'json'
require 'resolv'
require 'netaddr'

conf_dir = "#{__dir__}/dnsmasq"

# -------------------------------------------------------------------
# Update static address config
# -------------------------------------------------------------------
domains   = JSON.parse File.read("#{__dir__}/data/domains.json")
addresses = domains.to_a.map { |d| "address=/#{d[0]}/#{d[1]}" }
File.write "#{conf_dir}/addresses.conf", addresses.join("\n")

# -------------------------------------------------------------------
# Update domain resolv forward
# -------------------------------------------------------------------
blocked   = JSON.parse File.read("#{__dir__}/blocked.json")
forwarded = blocked['resolves'].map { |d| "server=/#{d}/208.67.222.222#443" }
File.write "#{conf_dir}/forwarded.conf", forwarded.join("\n")
