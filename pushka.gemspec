require_relative 'lib/pushka/version.rb'

Gem::Specification.new do |s|
  s.name        = 'pushka'
  s.version     = Pushka::VERSION
  s.date        = '2017-09-09'
  s.summary     = 'Rake task fast delivery tool'
  s.description = 'Rake task fast delivery tool'
  s.authors     = ['Zinovyev Ivan']
  s.email       = 'zinovyev.id@gmail.com'
  s.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end - %w[.rubocop.yml .travis.yml appveyor.yml]
  s.executables << 'pushka'
  s.homepage    = 'https://github.com/zinovyev/pushka'
  s.license     = 'MIT'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '~> 0.49.1'
end
