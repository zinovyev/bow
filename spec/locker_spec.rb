# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe Bow::Locker do
  let(:locker) do
    Bow::Locker.file_path = "#{Dir.pwd}/history"
    Bow::Locker.load!
  end

  before(:each) do
    locker.empty!
    locker.add('task1', true, false)
    locker.add('task2', false, false)
    locker.add('task3', true, false)
    locker.add('task3', false, true)
    locker.add('task3', true, false)
    locker.add('task3', false, true)
    locker.add('task3', true, false)
    locker.add('task3', false, true)
    locker.add('task4', true, false)
    locker.add('task5', true, true)
    locker.add('task6', true, false)
    locker.flush
  end

  describe '#find' do
    it 'should find all saved tasks' do
      expect(locker.find('task4')).to eq(
        record: "task4;\ttrue;\tfalse", first_c: 153, last_c: 170
      )
      expect(locker.find('task5')).to eq(
        record: "task5;\ttrue;\ttrue", first_c: 172, last_c: 188
      )
      expect(locker.find('task1')).to eq(
        record: "task1;\ttrue;\tfalse", first_c: 0, last_c: 17
      )
    end

    it 'should return a default stub for unknown task' do
      expect(locker.find('task8')).to eq(
        record: :not_found, first_c: nil, last_c: nil
      )
    end
  end

  describe '#reset' do
    it 'shoould not find removed task' do
      locker.reset('task7')
      locker.reset('task5')
      expect(locker.find('task5')).to eq(
        record: :not_found, first_c: nil, last_c: nil
      )
    end
  end

  describe '#applied?' do
    it 'should return proper values for applied tasks' do
      expect(locker.applied?('task1')).to eq true
      expect(locker.applied?('task3')).to eq false
    end
  end

  describe '#reverted?' do
    it 'should return proper values for reverted tasks' do
      expect(locker.reverted?('task1')).to eq false
      expect(locker.reverted?('task3')).to eq true
    end
  end

  describe '#apply' do
    it 'shoud be applied' do
      locker.apply('task7')
      expect(locker.applied?('task7')).to eq true
      expect(locker.reverted?('task7')).to eq false
    end
  end

  describe '#revert' do
    it 'shoud be reverted' do
      locker.revert('task7')
      expect(locker.applied?('task7')).to eq false
      expect(locker.reverted?('task7')).to eq true
    end
  end
end
