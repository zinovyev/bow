module Bow
  module Commands
    class Init < Command
      def description
        'Initialize minimal bow scaffold.'
      end

      def run
        InventoryExample.new.init
      end
    end
  end
end
