#! /usr/bin/env ruby

require 'resolv'
require 'netaddr'

# -------------------------------------------------------------------
# Update static address config
# -------------------------------------------------------------------
hosts = File.read("#{__dir__}/data/hosts.txt").split("\n")
File.open("#{__dir__}/dnsmasq/config/addresses.conf", 'w') do |f|
  hosts.each do |h|
    i, d = h.split ' '
    f.puts "address=/#{d}/#{i}"
  end
end

# -------------------------------------------------------------------
# Update domain resolv forward
# -------------------------------------------------------------------
sites = File.read("#{__dir__}/config/blocked_sites.txt").split("\n").select { |s| !s.empty? && !s.start_with?('#')}
File.open("#{__dir__}/dnsmasq/config/forwarded.conf", 'w') do |f|
  sites.each do |s|
    f.puts "server=/#{s}/208.67.222.222#443"
  end
end
