module Pushka
  class Command
    PROVISION_PATH = '/tmp/rake_provision'.freeze
    attr_reader :options, :hosts
    def initialize(options)
      @options = options
      @hosts = HostParser.new(options[:inventory])
    end
  end
end
