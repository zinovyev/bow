# frozen_string_literal: true

module Bow
  module Commands
    class Prepare < Command
      def description
        'Install RVM, Ruby and Rake on provisioned hosts'
      end

      def run
        ThreadPool.new do |t|
          t.from_enumerable targets do |host|
            result = SshHelper.prepare_provision(host.conn, PROVISION_PATH)
            ResponseFormatter.format(host, result)

            provision_cmd = "bash #{PROVISION_PATH}/preprovision.sh"
            result = SshHelper.execute(host.conn, provision_cmd)
            ResponseFormatter.format(host, result)
          end
        end
      end
    end
  end
end
