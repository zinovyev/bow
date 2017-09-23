require 'fileutils'

module Bow
  module Ssh
    class Rsync
      def initialize(ssh_helper)
        @ssh_helper = ssh_helper
      end

      def call(source, target)
        @ssh_helper.run(cmd_rsync(source, conn, target))
      end

      def cmd_rsync(source, conn, target)
        format(
          'rsync --contimeout=10 --force -r %s %s:%s',
          source,
          conn,
          target
        )
      end
    end
  end
end
