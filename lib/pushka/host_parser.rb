require 'json'

module Pushka
  class HostParser
    attr_reader :file, :hosts, :groups

    def initialize(file)
      @file = file
      @hosts = { all: [] }
      @groups = []
      @uniq_hosts = {}
    end

    def method_missing(m, *_args, &block)
      parse
      return hosts[m] unless block_given?
      hosts[m].each { |h| yield(h) }
    end

    def in_threads(group, &block)
      parse
      threads = []
      hosts[group.to_sym].each do |h|
        threads << Thread.new { block.call(h) }
      end

      threads.each { |thr| thr.join }
    end

    private

    def parse
      return if @parsed
      JSON.parse(File.read(@file)).each do |group, hosts|
        group = group.to_sym
        @groups << group
        @hosts[group] = [] unless @hosts[group]
        hosts.each do |host|
          record = host_record(host, group)
          @hosts[:all][host_index(host)] = record
          @hosts[group] << record
        end
      end
      @parsed = true
    end

    def host_index(host)
      @uniq_hosts[host] = @uniq_hosts.size unless @uniq_hosts[host]
      @uniq_hosts[host]
    end

    def host_record(host, group)
      {
        host: host,
        group: group,
        conn: "root@#{host}"
      }
    end

    def filename
      File.join(Dir.pwd, @file)
    end
  end
end
