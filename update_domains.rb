sites_file   = "#{__dir__}/conf/sites.list"
domains_file = "#{__dir__}/data/domains.list"

system 'scp pi@192.168.88.53:/var/log/dnsmasq.log /tmp/dnsmasq.log'

sites   = File.read(sites_file).split("\n").select { |s| !s.empty? && !s.start_with?('#')}
domains = File.read(domains_file).split("\n")

File.read('/tmp/dnsmasq.log').each_line do |l|
  if /: forwarded ([^\s]+) to/.match l
    unless sites.find_index { |s| $1.end_with? s }.nil?
      domains.push $1
    end
  end
end

File.write domains_file, domains.uniq.sort.join("\n")
