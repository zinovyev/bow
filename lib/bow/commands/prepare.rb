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
            result = app.ssh_helper(host).prepare_provision(PROVISION_PATH)
            ResponseFormatter.pretty_print(host, result)

            provision_cmd = "bash #{PROVISION_PATH}/preprovision.sh"
            result = app.ssh_helper(host).execute(provision_cmd)
            ResponseFormatter.pretty_print(host, result)
          end
        end
      end
    end
  end
end
