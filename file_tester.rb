#!/usr/bin/env ruby

require 'bow'

locker = Bow::Locker.load

locker.empty!
locker.add('task1', true, false)
locker.add('task2', false, false)
locker.add('task3', true, false)
locker.add('task3', true, false)
locker.add('task3', true, false)
locker.add('task3', true, false)
locker.add('task3', true, false)
locker.add('task3', false, true)
locker.add('task4', true, false)
locker.add('task5', true, true)
locker.add('task6', true, false)
locker.flush

p locker.find('task4')
p locker.find('task5')
p locker.find('task1')
p locker.find('task8')
p locker.find('task6')

locker.reset('task7')
locker.reset('task5')
# locker.reset('task1')
# p locker.find('task3')
p locker.find('task5')
locker.flush

p "TASK#1"
p locker.find('task1')
p locker.applied?('task1')
p locker.reverted?('task1')

p "TASK#3"
p locker.find('task3')
p locker.applied?('task3')
p locker.reverted?('task3')

p "TASK#7"
p locker.applied?('task7')
p locker.reverted?('task7')
p "TASK#7 apply"
locker.apply('task7')
p locker.applied?('task7')
p locker.reverted?('task7')
p "TASK#7 reverted"
locker.revert('task7')
p locker.applied?('task7')
p locker.reverted?('task7')

locker.apply('task1')
locker.revert('task1')
# puts locker.read
