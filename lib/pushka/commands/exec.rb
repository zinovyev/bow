module Pushka
  module Commands
    class Exec < Command
      def run
        raise ArgumentError, 'Command required!' unless cmd = ARGV.pop
        hosts.in_threads(options[:group]) do |host|
          result = SshHelper.execute(host[:conn], cmd)
          ResponseFormatter.format(host, result)
        end
      end
    end
  end
end
