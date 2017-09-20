# frozen_string_literal: true

module Bow
  class Config
    class << self
      def host
        @host ||= Config.new(:host)
      end

      def guest
        @guest ||= Config.new(:guest)
      end
    end

    GUEST_BASE_DIR = "#{Dir.home}/.bow"

    HOST_BASE_DIR = File.dirname(File.dirname(File.dirname(__FILE__))).freeze

    PATHS = {
      guest: {
        base_dir: GUEST_BASE_DIR,
        rake_dir: "#{GUEST_BASE_DIR}/rake",
        history: "#{GUEST_BASE_DIR}/history.json",
        pre_script: "#{GUEST_BASE_DIR}/provision.sh"
      },
      host: {
        base_dir: HOST_BASE_DIR,
        pre_script: "#{HOST_BASE_DIR}/src/provision.sh"
      }
    }.freeze

    def initialize(type)
      @type = type
    end

    def get(name)
      name.to_sym
      PATHS[@type][name]
    end

    def [](name)
      get(name)
    end
  end
end
