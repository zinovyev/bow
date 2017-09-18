require 'pry'

module Bow
  class Command
    PROVISION_PATH = '/tmp/rake_provision'.freeze

    attr_reader :options

    class << self
      attr_reader :all, :names

      def inherited(command_class)
        @all ||= []
        @names ||= []
        @all << command_class
        @names << command_class.command_name
      end

      def command_name
        @command_name ||= name.to_s
                              .split('::')
                              .last
                              .split(/([A-Z]{1}[^A-Z]*)/)
                              .reject(&:empty?)
                              .join('_')
                              .downcase
      end

      def find(name)
        index = @names.index name.to_s
        @all[index] if index
      end

      %w[usage description].each { |m| define_method(m) { new().send m } }
    end

    def initialize(argv = [], options = {})
      @argv = argv
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

    def targets
      load_inventory!
      user = @options[:user]
      group = @options[:group]
      targets = Targets.new(@targetfile, user)
      targets.hosts(group)
    end

    def load_inventory!
      return if @inventory_loaded
      inventory = Inventory.new
      inventory.ensure!
      @rakefile = inventory.rakefile
      @targetfile = inventory.targetfile
      @inventory_loaded = true
    end
  end
end
