# frozen_string_literal: true

require 'json'
require 'set'

module Bow
  Host = Struct.new(:host, :group, :conn)

  class Targets
    attr_reader :groups
    attr_accessor :file, :group, :user

    def initialize(file, user = 'root')
      @file = file
      @hosts = { all: Set.new }
      @user = user
      @groups = []
    end

    def hosts(group = :all)
      parse
      group = group.to_sym
      return @hosts[group] unless block_given?
      @hosts[group.to_sym].each { |h| yield(h) }
    end

    def parse
      return if @parsed
      raw_data.each do |group, hosts|
        parse_group(group, hosts)
      end
      @hosts[:all] = @hosts[:all].uniq
      @parsed = true
    end

    private

    def parse_group(group, hosts)
      group = group.to_sym
      hosts = hosts.uniq.map { |h| build_host(group, h) }
      @hosts[group] = Set.new hosts
      @hosts[:all] += hosts
      groups << group
    end

    def build_host(group, host)
      Host.new(host, group, "#{@user}@#{host}")
    end

    def raw_data
      @raw_data ||= JSON.parse(File.read(@file))
    end
  end
end
