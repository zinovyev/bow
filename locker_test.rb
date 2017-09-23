#!/usr/bin/env ruby

require 'bow'

locker = Bow::Locker.load
locker.empty!

(1..1000).each do |i|
  locker.add("task##{i}", i.even?, i.odd?)
end

(1..100).each do |i|
  locker.reset("task#{rand(1000)}")
end

(1..1000).each do |i|
  locker.find("task#{i}")
end
