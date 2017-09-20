# frozen_string_literal: true

module Bow
  class Options
    OPTIONS = [
      [
        '-uUSER',
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

    def initialize(options)
      @options = options
    end

    def parse(opts)
      OPTIONS.each do |definition|
        callable = definition.pop
        opts.on(*definition, method(callable))
      end
      opts.on_tail('-h', '--help', 'Print this help and exit.') do
        puts opts
        exit
      end
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
  end
end
