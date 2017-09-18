require 'json'

module Bow
  class TaskHistory
    class << self
      def load(*args)
        @instance ||= new(*args)
      end
    end

    attr_accessor :hist_file_path, :full_history

    def initialize(this_file_path = '/tmp/foo_hist.json')
      @this_file_path = this_file_path
      @modified = false
    end

    def read(task)
      full_history[task]
    end

    def add(task, step)
      prev_hist = (read(task) || {})
      write(task, prev_hist.merge(step))
    end

    def write(task, hist)
      full_history[task] = hist
      @modified = true
    end

    def full_history
      @full_history ||= begin
        raw_data = File.read(@this_file_path).to_s.strip
        raw_data.empty? ? {} : JSON.parse(raw_data)
      end
    end

    def flush
      json_hist = JSON.generate(@full_history)
      File.write(@this_file_path, json_hist)
    end

    def file
      @file ||= File.new(@this_file_path, 'r')
    end
  end
end
