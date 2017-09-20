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

    def initialize(conn)
      @conn = conn
    end

    def execute(cmd, timeout = 10)
      cmd = "ssh -o ConnectTimeout=#{timeout} #{conn} #{cmd}"
      run(cmd)
    end

    def copy(source, target = '/tmp')
      source = source.match?(%r{^\/}) ? source : File.join(Dir.pwd, source)
      cmd = "scp -r #{source} #{conn}:#{target}"
      run(cmd)
    end

    def prepare_provision(target_dir)
      result = execute("rm -rf #{target_dir}")
      merge_result(result, execute("mkdir -p #{target_dir}"))
      preprovision_script = "#{BASE_DIR}/src/preprovision.sh"
      merge_result(result, copy(preprovision_script, "#{target_dir}/"))
      %w[Rakefile rakelib files].each do |f|
        merge_result(result, copy(f, "#{target_dir}/"))
      end
      result
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
