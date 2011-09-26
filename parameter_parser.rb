def parse_params(log_path, proc)
  # we could use grep to get the parameters, which would probably be faster
  # but we'd have to suck the whole result into our memory space
  IO.foreach(log_path) { |raw_params|
    parms = parse_line(raw_params)
    parms && proc.call(parms)
  }
end

def parse_line
  return if !raw_params.start_with? '  Parameters:'
  eval(raw_params.slice(14, raw_params.length-2)) # oh shit! eval alert!
end

# example:
# log_proc = Proc.new { |parms|
#   print "#{parms['primaryEmail']['value']},#{parms['displayName']}\n"
# }

# parse_params('yyy', log_proc)
