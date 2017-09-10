require 'optparse'
require 'pry'

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

    OPTIONS = [
      [ '-uUSER',
        '--user=USER',
        'Remote user (root used by default)',
        :option_user
      ],
      [
        '-gGROUP',
        '--group=GROUP',
        'Hosts group (defined in config)',
        :option_group
      ],
      [
        '-iINVENTORY',
        '--inventory=INVENTORY',
        'Path to inventory file',
        :option_inventory
      ],
      [
        '-v',
        '--version',
        'Print version and exit',
        :option_version
      ]
    ].freeze

    COLUMN_WIDTH = 32

    EMPTY_COLUMN = (' ' * COLUMN_WIDTH).freeze

    def initialize
      @options = {
        user: 'root',
        group: 'all',
        inventory: 'hosts.json'
      }
    end

    def run
      opts = OptionParser.new do |opts|
        build_banner(opts)
        parse_options(opts)
      end
      opts.parse!
      parse_arguments(opts)
    end

    def build_banner(opts)
      banner = "#{BANNER}"
      banner << "\n\nCOMMANDS\n\n"
      COMMANDS.each { |n, i| banner << format_command(n, i) }
      banner << "OPTIONS\n\n"
      opts.banner = banner
    end

    def parse_options(opts)
      OPTIONS.each do |definition|
        callable = definition.pop
        opts.on(*definition, method(callable))
      end
      opts.on_tail('-h', '--help', 'Print this help and exit.') do
        puts opts
        exit
      end
    end

    def parse_arguments(opts)
      if ARGV.empty?
        ARGV << '-h'
        opts.parse!
      end
      command = ARGV.shift
      class_name = "Pushka::Commands::#{command.capitalize}"
      klass = Pushka::Commands.const_get(class_name)
      klass.new(@options).run
    rescue NameError => e
      raise e unless e.message =~ /uninitialized constant Pushka::Commands::/
      raise "Unknown command #{command}"
    end

    def option_user(user)
      @options[:user] = user
    end

    def option_group(group)
      @options[:group] = group
    end

    def option_inventory(inventory)
      @options[:inventory] = inventory
    end

    def option_version(_v)
      puts VERSION
      exit
    end

    def format_command(name, info)
      tail = ' ' * (32 - name.length)
      str = "     #{name}#{tail}#{info[:descr]}\n"
      str << "     #{EMPTY_COLUMN}USAGE: #{info[:usage]}\n\n"
    end
  end
end
