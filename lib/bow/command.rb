# frozen_string_literal: true

module Bow
  class Command
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

      %w[usage description].each { |m| define_method(m) { new.send m } }
    end

    attr_reader :app

    def initialize(app = nil, argv = [])
      @app = app
      @argv = argv
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

    def targets
      user = app.options[:user]
      group = app.options[:group]
      app.targets(user).hosts(group)
    end
  end
end
