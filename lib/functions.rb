require 'json'
require 'open-uri'
require 'resolv'
require_relative 'cidr-lite'

DNS_SERVER = Resolv::DNS.new nameserver_port: [['208.67.222.222', 443]]

def config(name)
  fetch_json "#{__dir__}/../config/#{name}.json"
end

def dns_resolv(domain)
  DNS_SERVER.getaddress(domain).to_s
end

def fetch_json(uri)
  JSON.parse open(uri).read
end

def save_json(path, data)
  File.write "#{__dir__}/../#{path}.json", JSON.pretty_generate(data)
end

def addr_merge(ranges)
  merger = CIDR::Lite.new
  ranges.each { |i| merger.add i }
  merger.list
end

def collect_all_ip_ranges
  ranges = Dir.glob "#{__dir__}/../ip-ranges/*.json"
  ranges.map! { |f| fetch_json f }
  ranges.flatten!

  ranges = ranges.concat config('hosts').values
  addr_merge ranges
end
