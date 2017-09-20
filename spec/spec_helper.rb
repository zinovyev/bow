# frozen_string_literal: true

require 'bundler/setup'
require 'bow'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.around(:each) do |example|
    @original_dir = Dir.pwd
    @testdir = File.join(__dir__, 'testdir')
    FileUtils.mkdir_p(@testdir)
    Dir.chdir(@testdir)
    example.run
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(@testdir)
  end
end
