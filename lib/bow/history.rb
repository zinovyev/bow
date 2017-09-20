# frozen_string_literal: true

require 'json'
require 'fileutils'
require 'objspace'

module Bow
  class History
    class << self
      attr_accessor :hist_file_path

      def load
        @instance ||= new
      end

      def load!
        @instance = nil
        @instance = new(true)
      end
    end

    VERSION_KEY = '__version'
    BLACKLIST = [VERSION_KEY].freeze

    include ObjectSpace

    attr_reader :full_history

    def initialize(skip_finalizer = false)
      @history_path = self.class.hist_file_path || Config.guest[:history]
      @modified = false
      define_finalizer(self, ->(_id) { flush }) unless skip_finalizer
    end

    def get(task)
      full_history[task]
    end

    def add(task, data)
      prev_hist = (get(task) || {})
      prev_hist[timestamp] = to_hash(data)
      write(task, prev_hist) unless BLACKLIST.include?(task)
    end

    def find(task, name)
      task_hist = get(task)
      return unless task_hist
      task_hist.values.detect { |val| val.keys.include? name }&.[](name)
    end

    def trunc(task)
      write(task, {}) unless BLACKLIST.include?(task)
    end

    def version
      @version ||= get(VERSION_KEY)
    end

    def flush
      return unless @modified
      json_hist = JSON.generate(@full_history)
      file.rewind
      file.write(json_hist)
      file.truncate(json_hist.size)
      file.close
      file(true)
    end

    private

    def to_hash(val)
      return val if val.is_a? Hash
      { value: val }
    end

    def timestamp
      Time.now.to_f.to_s.sub(/\./, '')
    end

    def write(task, hist)
      full_history[task] = hist
      @modified = true
    end

    def full_history
      @full_history ||= begin
        ensure_file(@history_path)
        raw_data = file.read.to_s.strip
        raw_data.empty? ? { VERSION_KEY => VERSION } : JSON.parse(raw_data)
      end
    end

    def file(reopen = false)
      @file = nil if reopen
      @file ||= File.open(@history_path, 'r+')
    end

    def ensure_file(name)
      return if File.exist?(name)
      FileUtils.mkdir_p(File.dirname(name))
      FileUtils.touch(name)
    end
  end
end
