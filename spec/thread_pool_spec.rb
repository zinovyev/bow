require 'spec_helper'

RSpec.describe Bow::ThreadPool do
  describe '#new' do
    let(:tp) { described_class.new }
    let(:procs) { [-> { 'foo0' }, -> { 'foo1' }, -> { 'foo2' }]  }
    before { procs.each { |p| tp.add(&p) } }

    it 'is expected to add all procs to the queue' do
      expect(tp.queue.count).to eq 3
    end

    it 'is expected to correctly wrap all procs' do
      tp.queue.each_with_index do |h, i|
        expect(h.call).to eq procs[i].call
      end
    end
  end

  describe '#from_enumerable' do
    let(:enum) { [1, 2, 3] }
    let(:handler) { proc { |v| v + 1 } }
    let!(:tp) do
      tp = described_class.new
      tp.from_enumerable enum, &handler
      tp
    end
    it 'is expected to register all elements from enumerable' do
      expect(tp.queue.count).to eq 3
    end

    it 'is expected to apply handler to all elements from enumerable' do
      tp.queue.each_with_index do |h, i|
        expect(h.call).to eq(2 + i)
      end
    end
  end
end

