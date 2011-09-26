def filter(http_method, action, status=nil)
  def match_status(line, status)
    return true if status.nil?
    # Completed 200 OK in 14ms (Views: 2.8ms)
    line[10..12] == status.to_s
  end

  printing = false
  buffer = ''
  IO.foreach('pm_cut.log') { |line|
    if line.start_with?("Started #{http_method}") && line.match(action)
      printing = true
      buffer = ''
    end

    buffer << line if printing

    if printing && line.start_with?('Completed')
      printing = false
      if match_status(line, status)
        print buffer
        print "\n\n"
      end
    end
  }
end

#filter('POST', 'legacy_register', 302)

