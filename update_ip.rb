#! /usr/bin/env ruby

require 'json'
require 'netaddr'
require 'open-uri'
require 'resolv'

ip_ranges  = {}

# -------------------------------------------------------------------
# Collect IP ranges from AWS and Cloudflare
# -------------------------------------------------------------------
ip_ranges['cloudflare'] = open('https://www.cloudflare.com/ips-v4').read.split("\n")
ip_ranges['aws']        = JSON.parse(open('https://ip-ranges.amazonaws.com/ip-ranges.json').read)['prefixes']
                              .select{ |p| p['service'] == 'AMAZON' }.map{ |p| p['ip_prefix'] }

# -------------------------------------------------------------------
# Collect IP ranges by ASN
# -------------------------------------------------------------------
asn = File.read("#{__dir__}/config/blocked_asn.txt").split("\n").map { |n| n.split /\s+/ }
asn.each do |n|
  raw_data  = `whois -h whois.radb.net -- '-i origin #{n[0]}' | grep route:`
  ranges    = raw_data.split("\n").map { |i| i.split(/\s+/).last }
  loop do
    length = ranges.count
    ranges = NetAddr.merge ranges
    break if ranges.count == length
  end
  ip_ranges[n[1]] = ranges
end

# -------------------------------------------------------------------
# Store IP ranges
# -------------------------------------------------------------------
ip_ranges.each do |r|
  File.write "#{__dir__}/data/ip_ranges/#{r[0]}.txt", r[1].join("\n")
end

# -------------------------------------------------------------------
# Fetch IP of blocked domains
# -------------------------------------------------------------------
dns_server = Resolv::DNS.new nameserver_port: [['208.67.222.222', 443]]
domains    = File.read("#{__dir__}/config/blocked_domains.txt").split("\n")
File.open "#{__dir__}/data/hosts.txt", 'w' do |f|
  domains.each do |d|
    begin
      ip = dns_server.getaddress(d).to_s
      f.puts "#{ip} #{d}"
    rescue;;end
  end
end

puts 'done'
