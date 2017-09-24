require 'fileutils'
require 'objspace'

# Locker is a task state manager.
# It tracks the task status and saves it to the history file.
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

    SEPARATOR = ";\t".freeze
    LINE_SEP = "\n".freeze
    NOT_FOUND = :not_found

    attr_accessor :runtime_cache

    def initialize
      @file_path = self.class.file_path || Config.guest[:history]
      @modified = false
      @file_opened = false
      @runtime_cache = {}
    end

    def applied?(task)
      record = parse(find(task))
      !!(record && record[1])
    end

    def reverted?(task)
      record = parse(find(task))
      !!(record && record[2])
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
        when 'true' then true
        when 'false' then false
        else v
        end
      end
    end

    def reset(task)
      meta = find(task)
      reset_cache(task)
      return if meta[:record] == NOT_FOUND
      file.seek(meta[:first_c], IO::SEEK_SET)
      str_len = meta[:last_c] - meta[:first_c] + 1
      file.write ' ' * str_len
    end

    def find(task)
      cached = from_cache(task)
      return cached if cached
      result = pure_find(task)
      result
    end

    def from_cache(task)
      @runtime_cache[task]
    end

    def to_cache(task, result)
      @runtime_cache[task] = result
    end

    def reset_cache(task)
      @runtime_cache[task] = nil
    end

    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Style/PerlBackrefs
    def pure_find(task)
      file.rewind
      current_line = ''
      first_c = 0
      last_c = 0
      file.each_char.with_index do |c, idx|
        if c == LINE_SEP
          current_line =~ /^([^\s]+)#{SEPARATOR}/
          to_cache(task, record: $1, first_c: first_c, last_c: last_c)
          if task == $1
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
    # rubocop:enable Style/PerlBackrefs
    # rubocop:enable Metrics/MethodLength

    def add(task, applied = false, reverted = false)
      reset(task)
      file.seek(0, IO::SEEK_END)
      write(task, applied, reverted)
      self
    end

    def write(task, applied = false, reverted = false)
      reset_cache(task)
      record = [task, applied, reverted].join(SEPARATOR)
      first_c = file.tell
      file.puts(record)
      last_c = first_c + record.size - 1
      to_cache(task, record: record, first_c: first_c, last_c: last_c)
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

    def compact
      compressed = ''
      file.each do |l|
        compressed << l unless l[0] == ' '
      end
      file.rewind
      file.write(compressed)
      file.truncate(compressed.size)
      @runtime_cache = {}
      @modified = true
      self
    end

    def empty!
      file.rewind
      file.truncate(0)
      @runtime_cache = {}
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
