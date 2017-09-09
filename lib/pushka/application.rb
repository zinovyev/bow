require 'optparse'

module Pushka
  class Application
    BANNER = 'Usage: pushka command arguments [options]'.freeze
    COMMANDS = {
      apply: {
        descr: 'Apply provision.',
        usage: 'pushka apply [options]'
      },
      ping: {
        descr: 'Check connection to the remote host.',
        usage: 'pushka ping [options]'
      },
      exec: {
        descr: 'Execute command on remote server.',
        usage: 'pushka exec cmd [options]'
      },
      preprovision: {
        descr: 'Prepare ruby & rake environment on remotes.',
        usage: 'pushka preprovision [options]'
      },
    }.freeze

    def initialize
      @options = {}
    end

    def run
      parse_options
      # parse_args
    end

    def build_banner
      banner = "#{BANNER}"
      banner << "\n"
      banner << "\n"
      banner << 'COMMANDS'
      banner << "\n"
      banner << "\n"

      COMMANDS.each { |n, i| banner << format_command(n, i) }

      banner << 'OPTIONS'
      banner << "\n"
      banner << "\n"

      banner
    end

    def format_command(name, info)
      whitespace = ' ' * (32 - name.length)
      str = '     ' 
      str << name.to_s
      str << whitespace
      str << "#{info[:descr]}\n"
      str << '     ' << ' ' * 32 << "USAGE: #{info[:usage]}\n\n"
    end

    def parse_arguments(command, meta)
      if ARGV.empty?
        ARGV << '-h'
        parse_options
        exit
      end
    end

    def parse_options
      OptionParser.new do |opts|
        opts.banner = build_banner
        opt_user(opts)
        opt_help(opts)
        opt_version(opts)
        opts.on('-command', 'Command description') {}
      end.parse!
    end

    def opt_user(opts)
      remote_user_msg = 'Specify remote user (root used by default)'
      opts.on('-u', '--user', remote_user_msg) do |v|
        @options[:verbose] = v
      end
    end

    def opt_help(opts)
      opts.on('-h', '--help', 'Print this help') do
        puts opts
        exit
      end
    end

    def opt_version(opts)
      opts.on('-v', '--version', 'Print version') do
        puts VERSION
        exit
      end
    end
  end
end
