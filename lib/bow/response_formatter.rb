# frozen_string_literal: true

module Bow
  class ResponseFormatter
    ERROR = "\033[31m%s\033[0m"
    INFO = "\033[33m%s\033[0m"
    SUCCESS = "\033[32m%s\033[0m"
    HEADER = "\033[1;35m%s\033[0m"

    class << self
      def pretty_print(*args)
        puts "#{wrap(*args)}\n"
      end

      def multi_print(host, results)
        results.each do |r|
          puts "#{wrap(host, r)}\n"
        end
      end

      def wrap(host, result)
        host_group = colorize("[#{host.group}]", HEADER)
        host_addr = colorize(host.host, HEADER)
        host_header = "\n#{host_group} #{host_addr}:\n\n"
        response = colorize_result(result).compact.first
        "#{host_header}#{response}"
      end

      def colorize_result(result)
        out, err = result.map { |m| m.to_s.strip }
        err = err.empty? ? nil : colorize(err, ERROR)
        out = if !out.empty?
                colorize(out, SUCCESS)
              elsif err.nil?
                colorize('DONE', INFO)
              end
        [out, err]
      end

      def colorize(msg, color_pattern)
        color_pattern % msg
      end
    end
  end
end
