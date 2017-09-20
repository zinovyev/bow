# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Style/ClassAndModuleChildren
class Bow::Commands::TestCommand < Bow::Command
end

RSpec.describe Bow::Command do
  describe '#command_name' do
    it 'should build a command name based on the class name' do
      expect(Bow::Commands::TestCommand.command_name).to eq 'test_command'
    end
  end

  describe '#find' do
    it 'should find a command by name' do
      expect(Bow::Command.find('test_command')).to eq(
        Bow::Commands::TestCommand
      )
    end
  end

  describe '#usage' do
    it 'should provide usage info' do
      expect(Bow::Commands::TestCommand.usage).to eq(
        'bow test_command [args] [options]'
      )
    end

    it 'should provide usage info for an instance' do
      expect(Bow::Commands::TestCommand.new({}).usage).to eq(
        'bow test_command [args] [options]'
      )
    end
  end

  describe '#description' do
    it 'should provide description' do
      expect(Bow::Commands::TestCommand.description).to eq(
        'Command test_command description'
      )
    end

    it 'should provide description for an instance' do
      expect(Bow::Commands::TestCommand.new({}).description).to eq(
        'Command test_command description'
      )
    end
  end
end
