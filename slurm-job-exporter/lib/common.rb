#!/bin/ruby

require 'date'

# Converts varying slurm runtime formats to seconds
def parseRuntime(runtime)
	# 7-22:12:48
	# 15:06:15
	# 00:03.271

	if runtime.match(/[0-9]*?-[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/) ; then
		days = runtime.split("-", 2)[0].to_i
		remainder = runtime.split("-",2)[1]

		hours = remainder.split(":",3)[0].to_i
		minutes = remainder.split(":",3)[1].to_i
		seconds = remainder.split(":",3)[2].to_i

		return (days * 86400) + (hours * 3600) + (minutes * 60) + seconds
	elsif runtime.match(/[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/) ; then
		hours = runtime.split(":",3)[0].to_i
		minutes = runtime.split(":",3)[1].to_i
		seconds = runtime.split(":",3)[2].to_i

		return (hours * 3600) + (minutes * 60) + seconds
	elsif runtime.match(/[0-9][0-9]:[0-9][0-9]\.[0-9][0-9][0-9]/) ; then
		minutes = runtime.split(":",2)[0].to_i
		seconds = runtime.split(":",2)[1].to_f.round(0).to_i

		return (minutes * 60) + seconds
	else
		$log.error "Unable to parse runtime #{runtime}"
		return 0
	end
end

# Function to parse the date and time
def parse_datetime(dt_str)
	return DateTime.strptime(dt_str, '%Y-%m-%dT%H:%M:%S')
end
  