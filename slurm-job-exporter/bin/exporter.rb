#!/bin/ruby

require 'net/http/server'

require_relative '../lib/config.rb'
require_relative '../lib/log.rb'
require_relative '../lib/common.rb'
require_relative '../lib/slurm.rb'

def collectMetrics()
	start_time = (Time.now - 300).strftime("%Y-%m-%dT%H:%M:%S")
	end_time = Time.now.strftime("%Y-%m-%dT%H:%M:%S")

	$log.info "Evaluating #{start_time} -> #{end_time}"

	completed_jobs = getCompleted(start_time, end_time)
	metrics = []

	completed_jobs.each do |job|
		metrics << "slurm_job_meta{jobid=\"#{job['id']}\", state=\"#{job['state']}\", partition=\"#{job['partition']}\", account=\"#{job['account']}\", user=\"#{job['user']}\", nodes=\"#{job['alloc_nodes']}\", cpus=\"#{job['alloc_cpus']}\", memory=\"#{job['alloc_mem']}\", gpus=\"#{job['alloc_gpus']}\", cpu_eff=\"#{job['cpu_eff']}\", mem_util=\"#{job['max_mem_util']}\", runtime=\"#{job['runtime_str']}\", runtime_sec=\"#{job['runtime']}\", wait_time=\"#{job['wait_time']}\", date=\"#{job['date']}\", day=\"#{job['day']}\", hour=\"#{job['hour']}\"} 1\n"
		metrics << "slurm_job_cpu_eff{jobid=\"#{job['id']}\", account=\"#{job['account']}\", user=\"#{job['user']}\"} #{job['cpu_eff']}\n"
		metrics << "slurm_job_mem_util{jobid=\"#{job['id']}\", account=\"#{job['account']}\", user=\"#{job['user']}\"} #{job['max_mem_util']}\n"
	end

	return metrics
end

def runServer()
	# Default port
	port = 9107

	# Override port from config if set
	if $CONFIG.key?('exporter') and $CONFIG['exporter'].key?('port') ; then
		port = $CONFIG['exporter']['port']
	end

	$log.info "Starting slurm job exporter on port #{port}.."

	Net::HTTP::Server.run(:port => port) do |request,stream|
		if request[:method] == "GET" and request[:uri][:path] == "/" ; then
			[200, {'Content-Type' => 'text/html'}, ['<html><head><title>Slurm Job Exporter</title></head><body><h1>Slurm Job Exporter</h1><p><a href="/metrics">Metrics</a></p></body></html>']]
		elsif request[:method] == "GET" and request[:uri][:path] == "/metrics"
			metrics = collectMetrics()
			[200, {'Content-Type' => 'text/html'}, [metrics.join('')]]
		else
			[404, {'Content-Type' => 'text/html'}, []]
		end
	end
end

runServer()
