#!/usr/bin/env ruby -i

# expects an IO object for the log_file
def filter(log_io, http_method=nil, request_path=nil, status_code=nil)
  def match_status(line, status)
    # Completed 200 OK in 14ms (Views: 2.8ms)
    status.nil? || line[10..12] == status.to_s
  end

  def match_request_path(line, request_path)
    request_path.nil? || line.match(request_path)
  end

  def match_http_method(line, http_method)
    http_method.nil? || line.start_with?("Started #{http_method}")
  end

  printing = false
  buffer = ''
  log_io.each { |line|
    if match_http_method(line, http_method) &&
       match_request_path(line, request_path)
      printing = true
      buffer = ''
    end

    buffer << line if printing

    if printing && line.start_with?('Completed')
      printing = false
      if match_status(line, status_code)
        print buffer
        print "\n\n"
      end
    end
  }
end

def main
  require 'optparse'
  require 'ostruct'

  def parse_arguments(args)
    options = OpenStruct.new
    # no defaults for options
    # options.some_opt = 'something'

    opts = OptionParser.new do |opts|
      opts.banner = <<USAGE
usage: filter_requests.rb [OPTION]... file
USAGE

      opts.on("--status-code CODE", Integer, "HTTP Response code") do |code|
        options.status_code = code
      end

      opts.on("--method METHOD", String, "HTTP Method") do |http_method|
        options.http_method = http_method
      end

      opts.on("--request-path REQUEST_PATH", String,
              "Request path, e.g. /posts/search") do |request_path|
        options.request_path = request_path
      end

      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
    end
    opts.parse!(args)
    if options.status_code.nil? &&
       options.http_method.nil? &&
       options.request_path.nil?
      puts "You must submit at least one filter parameter"
      puts opts
      exit
    end
    if ARGV.length == 0
      options.log_file = $stdin
    else
      options.log_file = File.new ARGV.last
    end
    options
  end
  opts = parse_arguments(ARGV)

  filter(opts.log_file, opts.http_method, opts.request_path, opts.status_code)
end

main() if __FILE__ == $0
