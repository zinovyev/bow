require 'rspec'
require 'rake/testtask'

task :test do
  system('bundle exec rspec')
  system('bundle exec rubocop')
end

desc 'Run tests'
task :default => :test
