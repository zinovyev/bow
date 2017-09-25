# frozen_string_literal: true

require_relative 'lib/bow/version.rb'

Gem::Specification.new do |s|
  s.name        = 'bow'
  s.version     = Bow::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Automate your infrastructure provisioning \
and configuration with Rake."
  s.description = s.summary
  s.authors     = ['Zinovyev Ivan']
  s.email       = 'zinovyev.id@gmail.com'
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end - %w[.rubocop.yml .travis.yml appveyor.yml]
  s.executables << 'bow'
  s.homepage    = 'https://github.com/zinovyev/bow'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rake', '~> 12.1'
  s.add_development_dependency 'pry', '~> 0.10.3'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.50.0'
end
