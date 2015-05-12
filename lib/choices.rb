#!/usr/bin/env ruby

require 'choice'

Choice.options do

  separator ''
  separator 'Update IP Ranges'

  option :update_ip_ranges do
    short '-i'
    long '--ip'
    desc 'Update IP ranges'
  end

  separator ''
  separator 'Make Rules Files'

  option :generate_config_files do
    short '-g'
    long '--generate'
    desc 'Generate config files'
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
