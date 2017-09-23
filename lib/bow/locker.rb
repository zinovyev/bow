require 'fileutils'
require 'objspace'

# Locker is a task state manager.
# It tracks the task status and saves it to the history file.
#
# * If task should run only once and is already applied
# * If task should run only once, is already applied and than is marked as reverted
# * If task that ran once should be 
#
module Bow
  class Locker
    class << self
      attr_accessor :file_path

      def load
        @instance ||= new
      end

      def load!
        @instance = new
      end
    end

    SEPARATOR = '  ::  '.freeze
    LINE_SEP = "\n".freeze
    NOT_FOUND = :not_found

    def initialize
      @file_path = self.class.file_path || Config.guest[:history]
      @modified = false
      @file_opened = false
    end

    def applied?(task)
      record = parse(find(task))
      record && record[1]
    end

    def reverted?(task)
      record = parse(find(task))
      record && record[2]
    end

    def apply(task)
      return if applied?(task)
      add(task, true, reverted?(task))
    end

    def revert(task)
      return if reverted?(task)
      add(task, applied?(task), true)
    end

    def parse(meta)
      return false if meta[:record] == NOT_FOUND
      record = meta[:record].split(SEPARATOR)
      record.map do |v|
        v.strip!
        case v
        when "true" then true
        when "false" then false
        else v
        end
      end
    end

    def reset(task)
      meta = find(task)
      return if meta[:record] == NOT_FOUND
      file.seek(meta[:first_c], IO::SEEK_SET)
      str_len = meta[:last_c] - meta[:first_c] + 1
      file.write ' ' * str_len
    end

    def find(task)
      file.rewind
      current_line = ''
      first_c = 0
      last_c = 0
      file.each_char.with_index do |c, idx|
        if c == LINE_SEP
          if current_line.match?(/^#{task}#{SEPARATOR}/)
            return { record: current_line, first_c: first_c, last_c: last_c }
          end
          current_line = ''
          first_c = idx + 1
          last_c = first_c
        else
          current_line << c
          last_c = idx
        end
      end
      { record: NOT_FOUND, first_c: nil, last_c: nil }
    end

    def add(task, applied = false, reverted = false)
      reset(task)
      file.seek(0, IO::SEEK_END)
      write(task, applied, reverted)
    end

    def write(task, applied = false, reverted = false)
      record = [task, applied, reverted].join(SEPARATOR)
      file.puts(record)
      @modified = true
      self
    end

    def flush
      return unless @modified && @file_opened
      file.close
      @file_opened = false
      @modified = false
      self
    end

    def empty!
      file.rewind
      file.truncate(0)
    end

    def file
      return @file if @file && @file_opened
      ensure_file(@file_path)
      @file = File.open(@file_path, 'r+')
      @file_opened = true
      file
    end

    def ensure_file(name)
      return if File.exist?(name)
      FileUtils.mkdir_p(File.dirname(name))
      FileUtils.touch(name)
    end
  end
end
