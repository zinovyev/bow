# frozen_string_literal: true

module Bow
  module Commands
    class Apply < Command
      def description
        'Apply provision on remote hosts.'
      end

      def run
        ThreadPool.new do |t|
          t.from_enumerable targets do |host|
            result = app.ssh_helper(host).prepare_provision(PROVISION_PATH)
            ResponseFormatter.pretty_print(host, result)

            cmd = "'cd #{PROVISION_PATH} && rake #{host.group}:provision'"
            result = app.ssh_helper(host).execute(cmd)
            ResponseFormatter.pretty_print(host, result)
          end
        end
      end
    end
  end
end
