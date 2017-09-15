require 'pry'

module Bow
  class Command
    PROVISION_PATH = '/tmp/rake_provision'.freeze

    attr_reader :options, :hosts

    class << self
      attr_reader :all, :names

      def inherited(command_class)
        @all ||= []
        @names ||= []
        @all << command_class
        @names << command_class.command_name
      end

      def command_name
        @command_name ||= name.to_s.split('::').last.downcase
      end

      def find(name)
        index = @names.index name.to_s
        @all[index] if index
      end

      %w[usage description].each { |m| define_method(m) { new({}).send m } }
    end

    def initialize(options)
      @options = options
    end

    def description
      @description ||= "Command #{command_name} description"
    end

    def usage
      @usage ||= "bow #{command_name} [args] [options]"
    end

    def command_name
      self.class.command_name
    end

    def hosts
      @hosts = HostParser.new(options[:inventory])
    end
  end
end
