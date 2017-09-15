module Bow
  module Commands
    class Ping < Command
      def description
        'Check connectivity to all given hosts.'
      end

      def run
        ARGV << 'echo pong'
        Exec.new(@options).run
      end
    end
  end
end
