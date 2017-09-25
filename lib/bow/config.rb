# frozen_string_literal: true

module Bow
  class Config
    class << self
      def host
        @host ||= Config.new(:host, HOST_BASE_DIR)
      end

      def guest
        @guest ||= Config.new(:guest, GUEST_BASE_DIR)
      end

      def guest_from_host
        @guest_from_host ||= Config.new(:guest, GUEST_FROM_HOST_BASE_DIR)
      end
    end

    HOST_BASE_DIR = File.dirname(File.dirname(File.dirname(__FILE__)))

    GUEST_BASE_DIR = "#{Dir.home}/.bow"

    GUEST_FROM_HOST_BASE_DIR = '~/.bow'

    PATHS = {
      guest: {
        base_dir: '%s',
        rake_dir: '%s/rake',
        history: '%s/.history',
        pre_script: '%s/provision.sh'
      },
      host: {
        base_dir: '%s',
        pre_script: '%s/src/provision.sh'
      }
    }.freeze

    def initialize(type, base_dir)
      @type = type
      @base_dir = base_dir
    end

    def get(name)
      name.to_sym
      value = PATHS[@type][name]
      substitude_dir(value)
    end

    def substitude_dir(orig)
      format(orig, @base_dir) if orig
    end

    def [](name)
      get(name)
    end
  end
end
