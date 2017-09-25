require 'fileutils'

module Bow
  module Ssh
    class Rsync
      def initialize(ssh_helper)
        @ssh_helper = ssh_helper
      end

      def call(source, target)
        @ssh_helper.run(cmd_rsync(source, target))
      end

      def cmd_rsync(source, target)
        format(
          'rsync --timeout=10 --force -r %s %s:%s',
          source,
          @ssh_helper.conn,
          target
        )
      end
    end
  end
end
