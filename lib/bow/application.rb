require 'optparse'

module Bow
  class Application
    BANNER = 'Usage: bow command arguments [options]'.freeze
    COLUMN_WIDTH = 32
    EMPTY_COLUMN = (' ' * COLUMN_WIDTH).freeze

    attr_accessor :argv, :options, :debug

    def initialize(argv)
      @options = {
        user: 'root',
        group: 'all',
        inventory: 'hosts.json'
      }
      @argv = argv.dup
      @ssh_helpers = {}
      @debug = false
    end

    # rubocop:disable Lint/ShadowingOuterLocalVariable
    def run
      opts = OptionParser.new do |opts|
        opts.banner = build_banner
        options_parser.parse(opts)
      end
      opts.parse!(argv)
      command = parse_arguments(opts)
      command.run
    end
    # rubocop:enable Lint/ShadowingOuterLocalVariable

    def inventory
      return @inventory if @inventory
      @inventory ||= Inventory.new
      @inventory.ensure!
    end

    def config
      Config
    end

    def ssh_helper(host)
      conn = host.conn
      @ssh_helpers[conn] ||= SshHelper.new(conn, self)
    end

    def targets(user)
      @targets ||= Targets.new(inventory.targetfile, user)
    end

    def debug?
      !!@debug
    end

    private

    def build_banner
      banner = BANNER.dup.to_s
      banner << "\n\nCOMMANDS\n\n"
      Command.all.each do |command|
        banner << format_command(command)
      end
      banner << "OPTIONS\n\n"
      banner
    end

    def parse_arguments(opts)
      if argv.empty?
        argv << '-h'
        opts.parse!(argv)
      end
      build_command(argv.shift, argv)
    end

    def build_command(name, argv = {})
      raise "Unknown command #{name}!" unless command_exists? name
      Command.find(name).new(self, argv)
    end

    def command_exists?(name)
      Command.names.include? name.to_s
    end

    def format_command(command)
      tail = ' ' * (32 - command.command_name.length)
      str = "     #{command.command_name}#{tail}#{command.description}\n"
      str << "     #{EMPTY_COLUMN}Usage: #{command.usage}\n\n"
    end

    def options_parser
      @options_parser ||= Options.new(@options)
    end
  end
end
