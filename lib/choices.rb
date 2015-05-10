#!/usr/bin/env ruby

require 'choice'

Choice.options do

  separator ''
  separator 'Update IP Ranges'

  option :fetch_ip_all do
    short '-f'
    long '--fetch-ip-all'
    desc 'Fetch all IP ranges'
  end

  option :fetch_ip_cf do
    long '--fetch-ip-cf'
    desc 'Fetch IP ranges of CloudFlare'
  end

  option :fetch_ip_aws do
    long '--fetch-ip-aws'
    desc 'Update IP ranges of AWS'
  end

  option :fetch_ip_asn do
    long '--fetch-ip-asn'
    desc 'Fetch IP ranges by ASNs list'
  end

  option :fetch_ip_domains do
    long '--fetch-ip-domains'
    desc 'Fetch IPs by domains'
  end

  separator ''
  separator 'Make Rules Files'

  option :rules_all do
    short '-r'
    long '--rules-all'
    desc 'Update all rules files'
  end

  option :rules_dns do
    long '--rules-dns'
    desc 'Update dns rules files'
  end

  option :rules_router do
    long '--rules-router'
    desc 'Update router rules files'
  end

  separator ''
  separator 'Misc'

  option :version do
    short '-v'
    long '--version'
    desc 'Show version'
    action do
      puts PROGRAM_VERSION
      exit
    end
  end
end
