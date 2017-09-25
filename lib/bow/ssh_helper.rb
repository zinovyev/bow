# frozen_string_literal: true

require 'open3'

module Bow
  class SshHelper
    class << self
      def method_missing(m, *args, &block)
        new(args.shift).send m, *args, &block
      end
    end

    COPY_TOOLS = { rsync: Ssh::Rsync, scp: Ssh::Scp }.freeze

    attr_reader :conn

    def initialize(conn, app)
      @app = app
      @conn = conn
    end

    def execute(cmd, timeout = 10, skip_chdir = false)
      cmd = if skip_chdir
              format("'%s'", cmd)
            else
              format(
                "'cd %s && %s'",
                @app.config.guest_from_host[:rake_dir],
                cmd
              )
            end
      cmd = "ssh -o ConnectTimeout=#{timeout} #{conn} #{cmd}"
      run(cmd)
    end

    def copy(source, target)
      source = source.match?(%r{^\/}) ? source : File.join(Dir.pwd, source)
      copy_tool.call(source, target)
    end

    def prepare_provision
      @app.inventory.ensure!
      results = []
      results << ensure_base_dir
      results << copy_preprovision_script
      results << copy_rake_tasks
      results
      # merge_results(*results)
    end

    def ensure_base_dir
      execute("mkdir -p #{@app.config.guest_from_host[:rake_dir]}", 10, true)
    end

    def copy_preprovision_script
      copy(
        @app.config.host[:pre_script],
        @app.config.guest_from_host[:pre_script]
      )
    end

    def copy_rake_tasks
      copy("#{@app.inventory.location}/*", @app.config.guest_from_host[:rake_dir])
    end

    def copy_tool
      return @copy_tool if @copy_tool
      unless (key = @app.options[:copy_tool]&.to_sym)
        key = COPY_TOOLS.keys.detect { |t| system("which #{t} &>/dev/null") }
        error = "Either #{COPY_TOOLS.keys.join(' or ')} should be installed!"
        raise error unless key
      end
      @copy_tool = COPY_TOOLS[key].new(self)
    end

    def merge_results(result1, *results)
      merged = result1.map { |v| [v] }
      results.each_with_object(merged) do |result, acc|
        result.each_with_index do |val, i|
          if val.is_a? Array
            acc[i] += val
          else
            acc[i] << val
          end
        end
      end
    end

    def run(cmd)
      return cmd if @app.debug?
      Open3.capture3(cmd).first(2)
    end
  end
end
