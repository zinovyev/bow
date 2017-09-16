require 'rspec'
require 'rake/testtask'

task :test do
  exec('bundle exec rspec && bundle exec rubocop')
end

desc 'Run tests'
task :default => :test
