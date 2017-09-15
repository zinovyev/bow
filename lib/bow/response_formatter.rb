module Bow
  class ResponseFormatter
    ERROR = "\033[31m%s\033[0m"
    INFO = "\033[33m%s\033[0m"
    SUCCESS = "\033[32m%s\033[0m"

    class << self
      def format(host, result)
        host_format = "[%.5s] %13s" % [host[:group], host[:host]]
        colorize(result).each { |msg| puts "#{host_format}: #{msg}" if msg }
      end

      def colorize(result)
        out, err = result.map(&:strip)
        err = err.empty? ? nil : ERROR % err
        out = case
              when !out.empty?; SUCCESS % out
              when err.nil?; INFO % 'DONE'
              end
        [out, err]    
      end
    end
  end
end
