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
            results = app.ssh_helper(host).prepare_provision
            ResponseFormatter.multi_print(host, results)

            provision_cmd = "BOW_VERSION=\"#{Bow::VERSION}\" \
bash #{@app.config.guest_from_host[:pre_script]}"
            result = app.ssh_helper(host).execute(provision_cmd)
            ResponseFormatter.pretty_print(host, result)
          end
        end
      end
    end
  end
end
