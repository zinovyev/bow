require_relative 'lib/pushka.rb'

Gem::Specification.new do |s|
  s.name        = 'pushka'
  s.version     = Pushka::VERSION 
  s.date        = '2017-09-09'
  s.summary     = 'Rake task fast delivery tool'
  s.description = 'Rake task fast delivery tool'
  s.authors     = ['Zinovyev Ivan']
  s.email       = 'zinovyev.id@gmail.com'
  s.files       = ['lib/pushka.rb', 'lib/pushka/version.rb']
  s.homepage    = 'https://github.com/zinovyev/pushka'
  s.license      = 'MIT'
end
