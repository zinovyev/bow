# frozen_string_literal: true

module Bow
  module Commands
    class Ping < Command
      def description
        'Check connectivity to all given hosts.'
      end

      def run
        @argv << 'echo pong'
        Exec.new(@app, @argv).run
      end
    end
  end
end
