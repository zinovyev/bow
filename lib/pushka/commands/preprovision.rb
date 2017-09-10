module Pushka
  module Commands
    class Preprovision < Command
      def run
        hosts.in_threads(@options[:group]) do |host|
          result = SshHelper.prepare_provision( host[:conn], PROVISION_PATH)
          ResponseFormatter.format(host, result)

          provision_cmd = "bash #{PROVISION_PATH}/preprovision.sh"
          result = SshHelper.execute(host[:conn], provision_cmd)
          ResponseFormatter.format(host, result)
        end
      end
    end
  end
end
