require 'pry'

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
        raise ArgumentError, 'Command required!' unless (cmd = @argv.pop)
        ThreadPool.new do |t|
          t.from_enumerable targets do |host|
            result = SshHelper.execute(host.conn, cmd)
            ResponseFormatter.format(host, result)
          end
        end
      end
    end
  end
end
