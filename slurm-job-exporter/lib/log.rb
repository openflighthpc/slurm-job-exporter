#!/bin/ruby

require 'logger'

# Default log path
log_path = "log/slurm-job-metrics.log"

if $CONFIG.key?('exporter') and $CONFIG['exporter'].key?('log') ; then
	log_path = $CONFIG['exporter']['log']
end

$log = Logger.new(log_path)
$log.level = Logger::INFO
