module Bow
  class ResponseFormatter
    ERROR = "\033[31m%s\033[0m".freeze
    INFO = "\033[33m%s\033[0m".freeze
    SUCCESS = "\033[32m%s\033[0m".freeze

    class << self
      def format(host, result)
        host_format = '[%.5s] %13s' % [host[:group], host[:host]]
        colorize(result).each { |msg| puts "#{host_format}: #{msg}" if msg }
      end

      def colorize(result)
        out, err = result.map(&:strip)
        err = err.empty? ? nil : ERROR % err
        out = if !out.empty?
                SUCCESS % out
              elsif err.nil?
                INFO % 'DONE'
              end
        [out, err]
      end
    end
  end
end
