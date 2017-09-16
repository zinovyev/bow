require 'spec_helper'
require 'fileutils'
require 'json'

RSpec.describe Bow::Targets do
  let(:raw_targets) do
    {
      'web' => ['83.229.16.144', '67.211.104.47'],
      'dbs' => ['41.218.111.239', '83.229.66.151'],
      'api' => ['213.255.246.32', '196.220.127.255']
    }
  end

  let(:targets) { described_class.new('./targets.json') }

  before(:each) do
    File.write('targets.json', raw_targets.to_json)
  end

  describe '#raw_targets' do
    it 'should read the same data as written' do
      expect(targets.send(:raw_data)).to eq raw_targets
    end
  end

  describe '#build_host' do
    it 'should build a valid structure' do
      host_struct = targets.send :build_host, 'web', '213.255.246.32'
      expect(host_struct.host).to eq '213.255.246.32'
      expect(host_struct.group).to eq 'web'
      expect(host_struct.conn).to eq 'root@213.255.246.32'
    end
  end

  describe '#parse' do
    it 'should be able to parse targets file' do
      targets.parse
      expect(targets.hosts(:dbs).map(&:host)).to eq(
        ['41.218.111.239', '83.229.66.151']
      )
      expect(targets.hosts(:dbs).map(&:group)).to eq(
        %i[dbs dbs]
      )
      expect(targets.hosts(:dbs).map(&:conn)).to eq(
        ['root@41.218.111.239', 'root@83.229.66.151']
      )
    end
  end

  describe '#hosts' do
    it 'should provide array of hosts' do
      expect(targets.hosts(:all).count).to eq 6
    end

    it 'should yield on every host in a group' do
      targets.hosts(:api) { |h| expect(h.host).to match(/([\d]{1,3}.?){4}/) }
    end
  end
end
