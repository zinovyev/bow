#!/usr/bin/env ruby

require 'bow'
require 'pry'

locker = Bow::Locker.load
locker.empty!

puts 'fill'
(1..1000).each do |i|
  print "\r#{i}/1000" if 0 == (i % 10)
  locker.add("task##{i}", i.even?, i.odd?)
end
locker.flush

puts 'reset'
(1..100).each do |i|
  print "\r#{i}/100" if 0 == (i % 10)
  t = "task##{rand(1000)}"
  locker.reset(t)
end
locker.flush

puts 'find'
(1..1000).each do |i|
  print "\r#{i}/1000" if 0 == (i % 10)
  locker.find("task##{i}")
end
