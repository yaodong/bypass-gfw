require 'json'
require 'netaddr'
require 'open-uri'

ip_ranges  = {}

# aws
p 'collecting aws ip ranges'
aws_ranges = JSON.parse open('https://ip-ranges.amazonaws.com/ip-ranges.json').read
ip_ranges['aws'] = aws_ranges['prefixes'].map { |p| p['ip_prefix'] }

# cloudflare cdn
p 'collecting cloudflare ip ranges'
ip_ranges['cloudflare'] = open('https://www.cloudflare.com/ips-v4').read.split("\n")

# ip ranges by ASN
asn = File.read("#{__dir__}/conf/asn.list").split("\n").map { |n| n.split /\s+/ }
asn.each do |n|
  p "collecting #{n[1]} #{n[0]} ranges"
  raw_data  = `whois -h whois.radb.net -- '-i origin #{n[0]}' | grep route:`
  ranges    = raw_data.split("\n").map { |i| i.split(/\s+/).last }
  loop do
    length = ranges.count
    ranges = NetAddr.merge ranges
    break if ranges.count == length
  end
  ip_ranges[n[1]] = ranges
end

# store
ip_ranges.each do |r|
  File.write "#{__dir__}/data/ip_ranges/#{r[0]}.list", r[1].join("\n")
end
