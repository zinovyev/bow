require 'optparse'
require 'pry'

module Bow
  class Application
    BANNER = 'Usage: bow command arguments [options]'.freeze
    COLUMN_WIDTH = 32
    EMPTY_COLUMN = (' ' * COLUMN_WIDTH).freeze

    attr_accessor :argv

    def initialize(argv)
      @options = {
        user: 'root',
        group: 'all',
        inventory: 'hosts.json'
      }
      @argv = argv.dup
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
      build_command(argv.shift, @options)
    end

    def build_command(name, options = {})
      raise "Unknown command #{name}!" unless command_exists? name
      Command.find(name).new(options)
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
