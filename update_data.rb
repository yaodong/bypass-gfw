#! /usr/bin/env ruby

require 'json'
require 'netaddr'
require 'open-uri'
require 'resolv'

blocked  = JSON.parse File.read("#{__dir__}/blocked.json")
data_dir = "#{__dir__}/data"

# -------------------------------------------------------------------
# Collect IP ranges from AWS and Cloudflare
# -------------------------------------------------------------------
blocked_ip_ranges = blocked['ip_ranges']

cloudflare_data   = open(blocked_ip_ranges['cloudflare']).read.split("\n")
File.write "#{data_dir}/ip_ranges/cloudflare.json", JSON.pretty_generate(cloudflare_data)

aws_data = JSON.parse(open(blocked_ip_ranges['aws']).read)['prefixes'].select{ |p| p['service'] == 'AMAZON' }.map{ |p| p['ip_prefix'] }
File.write "#{data_dir}/ip_ranges/aws.json", JSON.pretty_generate(aws_data)

# -------------------------------------------------------------------
# Collect IP ranges by ASN
# -------------------------------------------------------------------
blocked['networks'].each do |k, v|
  if not v.kind_of?(Array)
    v = [v]
  end
  ranges = []
  v.each do |n|
    raw_data  = `whois -h whois.radb.net -- '-i origin #{n}' | grep route:`
    ranges   += raw_data.split("\n").map { |i| i.split(/\s+/).last }
  end
  loop do
    length = ranges.count
    ranges = NetAddr.merge ranges
    break if ranges.count == length
  end
  File.write "#{data_dir}/ip_ranges/#{k}.json", JSON.pretty_generate(ranges)
end

# -------------------------------------------------------------------
# Fetch IP of blocked domains
# -------------------------------------------------------------------
open_dns   = ['208.67.222.222', 443]
dns_server = Resolv::DNS.new nameserver_port: [open_dns]
hosts      = Hash[ blocked['domains'].map{ |d| [d, dns_server.getaddress(d).to_s] } ]
File.write "#{data_dir}/domains.json", JSON.pretty_generate(hosts)
