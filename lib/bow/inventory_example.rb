# frozen_string_literal: true

require 'fileutils'
module Bow
  class InventoryExample
    TARGETING_EXAMPLE = {
      'example_group1' => [
        '192.168.50.27',
        '192.168.50.37'
      ],
      'example_group2' => [
        '192.168.50.47',
        '192.168.50.57'
      ]
    }.freeze

    RAKEFILE_EXAMPLE = <<-RAKEFILE.gsub(/^ {6}/, '').freeze
      require 'bow/rake'

      Rake.application.options.trace_rules = true

      PROVISION_DIR = '/tmp/rake_provision'

      namespace :example_group1 do
        task provision: :print_hello do
        end

        flow run: :once
        task :print_hello do
          sh 'echo "Hello from example group #1 server!"'
        end
      end

      namespace :example_group2 do
        task provision: :print_hello do
        end

        flow enabled: false, revert_task: :print_goodbye
        task :print_hello do
          sh 'echo "Hello from example group #2 server!"'
        end

        task :print_goodbye do
          sh 'echo "Goodbye! The task at example group #2 is disabled!"'
        end
      end
    RAKEFILE

    def init
      raise 'Can not init. Directory not empty!' unless Dir.empty?(Dir.pwd)
      {
        'Rakefile'     => RAKEFILE_EXAMPLE,
        'targets.json' => JSON.pretty_generate(TARGETING_EXAMPLE)
      }.each do |targ, code|
        f = File.open(targ, 'w')
        f.write(code)
        f.close
      end
    end
  end
end
