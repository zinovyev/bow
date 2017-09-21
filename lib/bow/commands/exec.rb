# frozen_string_literal: true

require 'pry'
require 'pp'

module Bow
  module Commands
    class Exec < Command
      def description
        'Exec command on remote hosts.'
      end

      def usage
        "bow #{command_name} command [args] [options]"
      end

      def run
        raise ArgumentError, 'Command required!' unless @argv && !@argv.empty?
        cmd = @argv.shift
        ThreadPool.new do |t|
          t.from_enumerable targets do |host|
            result = app.ssh_helper(host).execute(cmd)
            ResponseFormatter.pretty_print(host, result)
          end
        end
      end
    end
  end
end
