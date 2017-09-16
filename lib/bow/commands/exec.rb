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
        raise ArgumentError, 'Command required!' unless (cmd = ARGV.pop)
        hosts.in_threads(options[:group]) do |host|
          result = SshHelper.execute(host[:conn], cmd)
          ResponseFormatter.format(host, result)
        end
      end
    end
  end
end
