# frozen_string_literal: true

module Bow
  class ThreadPool
    attr_accessor :max_threads, :queue

    def initialize(max_threads = 4)
      @queue = []
      @threads = []
      @history = []
      @max_threads = max_threads
      return unless block_given?
      yield(self)
      run
    end

    def add(&task)
      add_task(task)
    end

    def run
      @queue.each do |task|
        wait
        run_task(task)
      end
      wait_for_all
    end

    def from_enumerable(enumerable, &block)
      enumerable.each do |params|
        task = build_task(block, params)
        add_task(task)
      end
    end

    private

    def run_task(task)
      thr = Thread.new(&task)
      @threads << thr
    end

    def build_task(handler, params)
      -> { handler.call(params) }
    end

    def add_task(task)
      @queue << task
    end

    def wait
      return if @threads.count < @max_threads
      until @threads.count < @max_threads
        active_threads = @threads.select(&:alive?)
        @history += (@threads - active_threads)
        @threads = active_threads
        sleep 0.001
      end
    end

    def wait_for_all
      return if @threads.empty?
      # @threads.map!(&:run)
      @threads.each(&:join)
    end
  end
end
