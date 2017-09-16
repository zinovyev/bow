require 'spec_helper'

RSpec.describe Bow::Application do
  EXISTING_COMMANDS = %w[apply exec init ping prepare].freeze

  let(:argv) { [] }

  let(:application) { Bow::Application.new(argv) }

  let(:options) { OptionParser.new }

  describe '#build_banner' do
    it 'should build a vaalid banner' do
      banner = application.send :build_banner
      expect(banner).to match(/Usage:.*COMMANDS.*OPTIONS/m)
      EXISTING_COMMANDS.each { |c| expect(banner).to match(/#{c}/m) }
    end
  end

  describe '#parse_arguments' do
    context 'argv is empty' do
      it 'should call the help method' do
        expect(options).to receive(:parse!).with(['-h'])
        allow(application).to receive(:build_command).and_return(true)
        application.send :parse_arguments, options
      end
    end

    context 'called with unknown command' do
      let(:argv) { [':wq'] }
      it 'should provide an error' do
        error_msg = 'Unknown command :wq!'
        expect { application.send :parse_arguments, options }.to(
          raise_error(error_msg)
        )
      end
    end

    context 'called with existing command' do
      let(:argv) { ['init'] }
      it 'should provide an error' do
        expect(application).to receive(:build_command).and_return(true)
        application.send :parse_arguments, options
      end
    end
  end

  describe '#command_exists?' do
    it 'should find a command' do
      expect(application.send(:command_exists?, 'init')).to be_truthy
    end

    it 'should not find unexisting command' do
      expect(application.send(:command_exists?, 'info')).to be_falsey
    end
  end

  describe '#build_command' do
    it 'should build a command' do
      expect(application.send(:build_command, :prepare)).to be_an_instance_of(
        Bow::Commands::Prepare
      )
    end
  end
end
