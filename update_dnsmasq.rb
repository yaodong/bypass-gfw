require 'resolv'
require 'netaddr'

data_path = "#{__dir__}/data"
domains_file = "#{data_path}/domains.list"

hosts      = {}
ip_ranges  = Dir.glob("#{data_path}/ip_ranges/*.list").map { |f| File.read(f).split("\n") }.flatten
domains    = File.read(domains_file).split("\n")
dns_server = Resolv::DNS.new nameserver_port: [['208.67.222.222', 443]]

domains.each do |d|
  begin
    p "resolving #{d}"
    hosts[d] = dns_server.getaddress(d).to_s
  rescue => detail
    p "resolving #{d} fail: #{detail}"
  end
end

ip_ranges_test = ip_ranges.map { |r| NetAddr::CIDR.create r }

hosts.each do |h|
  if ip_ranges_test.find_index { |t| t.contains? h[1] }.nil?
    ip_ranges.push h[1]
  else
    p "deleted #{h[0]}"
    hosts.delete h[0]
  end
end

File.open("#{data_path}/dnsmasq/address.conf", 'w') do |f|
  hosts.each do |h|
    f.write "address=/#{h[0]}/#{h[1]}\n"
  end
end

File.open("#{data_path}/router.rules", 'w') do |f|
  ip_ranges.each do |i|
    f.write "/ip route remove [/ip route find dst-address=#{i}]\n"
    f.write "/ip route add dst-address=#{i} gateway=pptp-out1 comment=gfw\n"
  end
end

File.open("#{data_path}/dnsmasq/forwarded.conf", 'w') do |f|
  sites = File.read("#{data_path}/sites.list").split("\n").select { |s| !s.empty? && !s.start_with?('#')}
  sites.each do |s|
    f.write "server=/#{s}/208.67.222.222#443\n"
  end
end
