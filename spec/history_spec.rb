# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Bow::History do
  let(:test_config) do
    {
      base_dir:    '.',
      rake_dir:    './rake',
      history:     "#{Dir.pwd}/history.json",
      pre_script:  './provision.sh'
    }
  end

  let(:history) { Bow::History.load! }

  before(:each) do
    allow(Bow::Config).to receive(:guest).and_return test_config
  end

  describe '#load' do
    let(:history) { Bow::History.load }
    it 'should provide a singleton object' do
      expect(Bow::History.load). to eq(history)
    end
  end

  describe '#add' do
    it 'should be able to save a value to history' do
      history.add(:test, available: true)
      expect(history.get(:test).values).to eq [{ available: true }]
    end
  end

  describe '#find' do
    it 'should be able to search a value in history' do
      history.add(:test, key: 'correct value')
      history.add(:test, 'incorrect value')
      history.add(:test, another_key: 'another value')
      expect(history.find(:test, :key)).to eq 'correct value'
    end
  end

  describe '#flush' do
    it 'should be able to save state to file' do
      history.add(:test, key: 'correct value')
      history.flush
      expect(File.exist?('history.json')).to eq true
    end
  end

  describe '#version' do
    it 'should provide a valid version information' do
      expect(history.version).to eq Bow::VERSION
    end
  end
end
