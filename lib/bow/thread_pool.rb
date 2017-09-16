module Bow
  class ThreadPool
    attr_accessor :handler, :collection

    def initialize(thread_count = 4, &block)
      @thread_count = thread_count
      @queue = []
      @threads = []
      @handler = proc {}
      yield(self) if block_given?
    end

    def join
      i = 0
      collection.each do |*args|
        thr = Thread.new { handler.call(*args) }
        @threads << thr
      end
      @threads.each { |thr| thr.join }
      # @threads = []
    end

    def add(&block)
      @queue << block
    end

    def run
      while !@queue.empty?
        run_sequence
      end
    end

    def run_sequence
      p 'seq'
      while (@threads.size <= @thread_count - 1) && !@queue.empty?
        block = @queue.shift
        @threads << Thread.new(&block)
      end
      @threads.each(&:join)
      @threads = []
    end
  end
end
