require 'fileutils'

module Bow
  module Ssh
    class Scp
      def initialize(ssh_helper)
        @ssh_helper = ssh_helper
      end

      def call(source, target)
        @ssh_helper.execute(cmd_rm(target)) if cleanup_needed?
        @ssh_helper.run(cmd_scp(source, target))
        @ssh_helper.run(cmd)
      end

      def cmd_scp(source, target)
        format(
          'scp -o ConnectTimeout -r %s %s:%s',
          source,
          @ssh_helper.conn,
          target
        )
      end

      def cmd_rm(target)
        format('rm -rf %s', target)
      end

      def cleanup_needed?(source, target)
        File.basename(source) == File.basename(target)
      end
    end
  end
end
