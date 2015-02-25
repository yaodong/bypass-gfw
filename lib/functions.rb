require 'json'
require 'open-uri'
require 'resolv'
require_relative 'addr_merger'

CONFIG     = JSON.parse File.read("#{ROOT_PATH}/config.json")
DNS_SERVER = Resolv::DNS.new( nameserver_port: [['208.67.222.222', 443]] )

def read_json_url(uri)
  JSON.parse open(uri).read
end

def read_json_file(path)
  JSON.parse open("#{ROOT_PATH}/#{path}.json").read
end

def read_url(url)
  open(url).read
end

def save_json(path, data)
  File.write "#{ROOT_PATH}/#{path}.json", JSON.pretty_generate(data)
end

def save_ip_ranges(group, data)
  save_json "data/ip-ranges/#{group}", data
end

def get_address(domain)
  DNS_SERVER.getaddress domain
end

def addr_merge(ranges)
  merger = AddrMerger.new
  ranges.each { |i| merger.add i }
  merger.list
end
