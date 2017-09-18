require 'fileutils'

# rubocop:disable Layout/IndentHeredoc
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
      Rake.application.options.trace_rules = true

      PROVISION_DIR = '/tmp/rake_provision'

      namespace :example_group1 do
        task :provision do
          sh 'echo "Hello from example group #1 server!"'
        end
      end

      namespace :example_group2 do
        task :provision do
          sh 'echo "Hello from example group #2 server!"'
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