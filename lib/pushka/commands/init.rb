module Pushka
  module Commands
    class Init < Command
      def run
        DirChecker.new.prepare_dir!
      end
    end
  end
end
