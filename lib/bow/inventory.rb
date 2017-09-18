require 'rake/file_list'

module Bow
  class Inventory
    DEFAULT_RAKEFILES = [
      'Rakefile',
      'rakefile',
      'Rakefile.rb',
      'rakefile.rb'
    ].freeze

    DEFAULT_TARGETFILES = [
      # 'bow.yaml',
      # 'bow.rb',
      'targets.json'
    ].freeze

    attr_reader :rakefile, :targetfile, :location

    def initialize
      @rakefiles = DEFAULT_RAKEFILES.dup
      @targetfiles = DEFAULT_TARGETFILES.dup
      @original_dir = Dir.pwd
    end

    def parse
      return if @inventory_loaded
      rakefile, targetfile, @location = inventory_location
      @rakefile = File.join(@location, rakefile) if rakefile
      @targetfile = File.join(@location, targetfile) if targetfile
      @inventory_loaded = true
    end

    def valid?
      parse
      !!(rakefile && targetfile && location)
    end

    def ensure!
      parse
      [
        ['Rakefile', @rakefile, @rakefiles],
        ['Target file', @targetfile, @targetfiles]
      ].each do |name, file, variants|
        unless file
          raise "No #{name} found (looking for: #{variants.join(', ')})"
        end
      end
      true
    end

    private

    def inventory_location
      reset_path do
        here = @original_dir
        until (files = inspect_dir)
          break if here == '/'
          Dir.chdir('..')
          here = Dir.pwd
        end
        [files, here].flatten
      end
    end

    def reset_path
      yield
    ensure
      Dir.chdir(@original_dir)
    end

    def inspect_dir
      rakefile = detect_files(@rakefiles)
      targetfile = detect_files(@targetfiles)
      [rakefile, targetfile]
    end

    def detect_files(variants)
      variants.detect { |fn| File.exist?(fn) }
    end
  end
end
