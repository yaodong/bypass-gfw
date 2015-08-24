#!/usr/bin/env ruby

require 'json'
require 'open-uri'
require 'resolv'
require_relative 'addr_merger'

module Butter
  class Handler

    CONFIG     = JSON.parse File.read("#{ROOT_PATH}/config.json")
    DNS_SERVER = Resolv::DNS.new({nameserver_port: [['208.67.222.222', 443]]})

    def update_ip_ranges
      %w[aws cf domains asn].each do |fact|
        send "fetch_ip_#{fact}"
      end
      combine_ip_ranges
    end

    def fetch_ip_aws
      data = read_json_url 'https://ip-ranges.amazonaws.com/ip-ranges.json'
      data = data['prefixes'].keep_if do |p|
        p['service'] == 'AMAZON' && !p['region'].start_with?('cn-')
      end
      data.map! { |p| p['ip_prefix'] }
      save_ip_ranges 'aws', data
    end

    def fetch_ip_cf
      data = read_url('https://www.cloudflare.com/ips-v4').split("\n")
      save_ip_ranges 'cloudflare', data
    end

    def fetch_ip_domains
      save_ip_ranges 'domains', CONFIG['domains'].map { |h| DNS_SERVER.getaddress h }
    end

    def fetch_ip_asn
      CONFIG['networks'].each do |name, asn_list|
        ranges = Array(asn_list).map do |asn|
          result = `whois -h whois.radb.net -- '-i origin #{asn}'`
          result = result.split("\n").grep(/^route:/)
          result.map { |i| i.split(/\s+/).last }
        end
        ranges.flatten!
        ranges = addr_merge ranges
        save_ip_ranges name, ranges
      end
    end

    def combine_ip_ranges
      ranges = Dir.glob "#{ROOT_PATH}/data/ip-ranges/*.json"
      ranges.map! { |f| JSON.parse open(f).read }
      ranges.flatten!
      ranges = addr_merge ranges
      save_json 'data/ip-ranges', ranges
    end

    def generate_config_files
      rules_dns
      rules_router
    end

    def rules_dns
      data_dir  = "#{ROOT_PATH}/data/dnsmasq/dnsmasq.d"
      domains   = CONFIG['domains']
      addresses = read_json_file 'data/ip-ranges/domains'

      File.open "#{data_dir}/addresses.conf", 'w' do |f|
        domains.zip(addresses).each do |domain, address|
          f.puts "address=/#{domain}/#{address}"
        end
      end

      forwarded = CONFIG['resolving'].map { |domain| "server=/#{domain}/127.0.0.1#5353" }
      File.write "#{data_dir}/forwarded.conf", forwarded.join("\n")
    end

    def rules_router
      vpn_gateway = 'pptp-out1'
      ip_ranges   = read_json_file 'data/ip-ranges'
      rules = ['/ip route remove [/ip route find gateway=pptp-out1 comment=gfw-butter]']
      rules.concat ip_ranges.map{ |i| "/ip route add dst-address=#{i} gateway=#{vpn_gateway} comment=gfw-butter" }
      File.write "#{ROOT_PATH}/data/router_os/rules.txt", rules.join("\n")
    end

    private

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

      def addr_merge(ranges)
        merger = AddrMerger.new
        ranges.each { |i| merger.add i }
        merger.list
      end


  end
end


