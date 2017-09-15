module Bow
  module Commands
    class Init < Command
      def description
        'Initialize minimal bow scaffold.'
      end

      def run
        DirChecker.new.prepare_dir!
      end
    end
  end
end
