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
            result = ssh_helper(host).prepare_provision(PROVISION_PATH)
            ResponseFormatter.format(host, result)

            cmd = "'cd #{PROVISION_PATH} && rake #{host.group}:provision'"
            result = ssh_helper(host).execute(cmd)
            ResponseFormatter.format(host, result)
          end
        end
      end
    end
  end
end
