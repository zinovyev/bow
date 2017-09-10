module Pushka
  module Commands
    class Ping < Command
      def run
        ARGV << 'echo pong'
        Exec.new(@options).run
      end
    end
  end
end
