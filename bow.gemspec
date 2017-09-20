# frozen_string_literal: true

require_relative 'lib/bow/version.rb'

Gem::Specification.new do |s|
  s.name        = 'bow'
  s.version     = Bow::VERSION
  s.date        = '2017-09-09'
  s.summary     = 'Simple provisioning via rake tasks'
  s.description = 'Simple provisioning via rake tasks'
  s.authors     = ['Zinovyev Ivan']
  s.email       = 'zinovyev.id@gmail.com'
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end - %w[.rubocop.yml .travis.yml appveyor.yml]
  s.executables << 'bow'
  s.homepage    = 'https://github.com/zinovyev/bow'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rake'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rubocop'
end
