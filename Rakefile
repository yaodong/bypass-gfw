
require_relative 'lib/functions'

task default:  %w(ip_fetch dnsmasq router_os)
task ip_fetch: %w(ip_aws ip_cf ip_asn ip_combine)

task :ip_aws do
  data = fetch_json 'https://ip-ranges.amazonaws.com/ip-ranges.json'
  data = data['prefixes'].keep_if do |p|
    p['service'] == 'AMAZON' && !p['region'].start_with?('cn-')
  end
  data.map! { |p| p['ip_prefix'] }
  save_json 'ip-ranges/aws', data
end

task :ip_cf do
  data = open('https://www.cloudflare.com/ips-v4').read.split("\n")
  save_json 'ip-ranges/cloudflare', data
end

task :ip_asn do
  config('asn_lists').each do |name, asn_list|
    ranges = Array(asn_list).map do |asn|
      result = `whois -h whois.radb.net -- '-i origin #{asn}'`
      result = result.split("\n").grep(/^route:/)
      result.map { |i| i.split(/\s+/).last }
    end
    ranges.flatten!
    ranges = addr_merge ranges
    save_json "ip-ranges/#{name}", ranges
  end
end

task :ip_combine do
  ranges = collect_all_ip_ranges
  save_json 'deploy/ip-ranges/combined', ranges
end

task :router_os do
  vpn_gateway = 'pptp-out1'
  ip_ranges   = collect_all_ip_ranges

  rules = ['/ip route remove [/ip route find gateway=pptp-out1 comment=gfw-butter]']
  rules.concat ip_ranges.map{ |i| "/ip route add dst-address=#{i} gateway=#{vpn_gateway} comment=gfw-butter" }

  File.write "#{__dir__}/deploy/router_os/rules.txt", rules.join("\n")
end

task :dnsmasq do
  data_dir = "#{__dir__}/deploy/dnsmasq/dnsmasq.d"

  addresses = []
  config('hosts').each_pair do |domain, ip|
    addresses << "address=/#{domain}/#{ip}"
  end
  File.write "#{data_dir}/addresses.conf", addresses.join("\n")

  forwarded = config('poisoned_domains').map { |d| "server=/#{d}/127.0.0.1#5353" }
  File.write "#{data_dir}/forwarded.conf", forwarded.join("\n")
end

task :update_hosts do
  hosts = config('hosts')
  hosts.update(hosts) do |k|
    dns_resolv k
  end
  save_json 'config/hosts', hosts
end
