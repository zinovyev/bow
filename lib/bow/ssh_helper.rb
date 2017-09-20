# frozen_string_literal: true

require 'open3'

module Bow
  class SshHelper
    class << self
      def method_missing(m, *args, &block)
        new(args.shift).send m, *args, &block
      end
    end

    attr_reader :conn

    def initialize(conn, config, inventory)
      @conn = conn
      @config = config
      @inventory = inventory
      @copy_tool = find_copy_tool
    end

    def execute(cmd, timeout = 10)
      cmd = "ssh -o ConnectTimeout=#{timeout} #{conn} #{cmd}"
      run(cmd)
    end

    def copy(source, target, force = false)
      send @copy_tool, source, target, force
    end

    def prepare_provision
      @inventory.ensure!
      result = ensure_base_dir
      merge_result(result, copy_preprovision_script)
      merge_result(result, copy_rake_tasks)
      result
    end

    def ensure_base_dir
      execute("mkdir -p #{Config.guest_from_host[:base_dir]}")
    end

    def copy_preprovision_script
      copy(Config.host[:pre_script], Config.guest_from_host[:pre_script], true)
    end

    def copy_rake_tasks
      copy(@inventory.location, Config.guest_from_host[:rake_dir], true)
    end

    def find_copy_tool
      if system('which rsync &>/dev/null')
        :copy_with_rsync
      elsif system('which scp &>/dev/null')
        :copy_with_scp
      else
        raise 'Either scp or rsync should be installed!'
      end
    end

    def copy_with_scp(source, target, force = false)
      return unless source && target && (target.size > 3)
      source = source.match?(%r{^\/}) ? source : File.join(Dir.pwd, source)
      execute("rm -rf #{target}") if force
      cmd = "scp -r #{source} #{conn}:#{target}"
      run(cmd)
    end

    def copy_with_rsync(source, target, _force = false)
      return unless source && target && (target.size > 3)
      source = source.match?(%r{^\/}) ? source : File.join(Dir.pwd, source)
      cmd = "rsync --force -r #{source} #{conn}:#{target}"
      run(cmd)
    end

    def merge_result(result1, result2)
      result1[0] << result2[0]
      result1[1] << result2[1]
    end

    def run(cmd)
      Open3.capture3(cmd).first(2)
    end
  end
end
