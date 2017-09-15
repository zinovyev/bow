require 'spec_helper'
require 'fileutils'

RSpec.describe Bow::Inventory do
  let(:inventory) { Bow::Inventory.new }

  describe '#parse' do
    before { %w[Rakefile targets.json].each { |f| FileUtils.touch f } }
    it 'expect to have valid #rakefile, #targetfile, #location values' do
      inventory.parse
      expect(inventory.rakefile).to eq "#{Dir.pwd}/Rakefile"
      expect(inventory.targetfile).to eq "#{Dir.pwd}/targets.json"
      expect(inventory.location).to eq Dir.pwd
    end
  end

  describe '#valid?' do
    subject { inventory.valid? }
    it { is_expected.to be_falsey }

    context 'with Rakefile' do
      before { FileUtils.touch 'Rakefile' }
      it { is_expected.to be_falsey }

      context 'with targets.json file' do
        before { FileUtils.touch 'targets.json' }
        it { is_expected.to be_truthy }
      end
    end
  end

  describe '#ensure!' do
    it 'should raise' do
      msg = ['No Rakefile found (looking for: rakefile, ',
             'Rakefile, rakefile.rb, Rakefile.rb)'].join
      expect { inventory.ensure! }.to raise_error msg
    end

    context 'with Rakefile' do
      before { FileUtils.touch 'Rakefile' }
      it 'should raise' do
        msg = 'No Target file found (looking for: targets.json)'
        expect { inventory.ensure! }.to raise_error msg
      end

      context 'with targets.json file' do
        before { FileUtils.touch 'targets.json' }
        it { expect(inventory.ensure!).to be_truthy }
      end
    end
  end
end
