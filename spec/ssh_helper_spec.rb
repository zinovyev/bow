
# frozen_string_literal: true

require 'spec_helper'
require 'fileutils'

RSpec.describe Bow::SshHelper do
  let(:test_app) do
    app = Bow::Application.new([])
    app.debug = true
    app
  end

  let(:ssh_helper) do
    Bow::SshHelper.new('root@127.0.0.1', test_app)
  end

  describe '#execute' do
    it 'should provide a valid comand string' do
      cmd = 'echo "Hello World"'
      out = 'ssh -o ConnectTimeout=10 root@127.0.0.1 echo "Hello World"'
      expect(ssh_helper.execute(cmd)).to eq out
    end
  end

  describe '#copy_tool' do
    context 'force ssh copy tool' do
      before do
        test_app.options[:copy_tool] = 'scp'
      end
      it 'should choose a proper copy tool' do
        expect(ssh_helper.copy_tool).to be_an_instance_of(Bow::Ssh::Scp)
      end
    end

    context 'force rsync copy tool' do
      before do
        test_app.options[:copy_tool] = 'rsync'
      end
      it 'should choose a proper copy tool' do
        expect(ssh_helper.copy_tool).to be_an_instance_of(Bow::Ssh::Rsync)
      end
    end
  end

  describe '#merge_results' do
    it 'should merge 2 results properly' do
      result = ssh_helper.merge_results([1, 2], [3, 4])
      expect(result).to eq [[1, 3], [2, 4]]
    end

    it 'should merge 3 results properly' do
      result = ssh_helper.merge_results([1, 2], [3, 4], [5, 6])
      expect(result).to eq [[1, 3, 5], [2, 4, 6]]
    end
  end
end
