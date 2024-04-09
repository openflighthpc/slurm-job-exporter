#!/bin/ruby

# Returns seff like stats for completed jobs within start_time -> end_time
def getCompleted(start_time, end_time)
	sacct_output = `sacct -s cd,f,to,dl,nf --starttime #{start_time} --endtime #{end_time} -o JobID,State,Account,User,Elapsed,AllocCPUs,ReqMem,NNodes,Partition --parsable2 --noheader --noconvert --allocations`

	completed_jobs = []

	sacct_output.each_line do |job_line|
		parts = job_line.split("|")

		#JobID,State,Account,User,Elapsed,AllocCPUs,TotalCPU,ReqMem	
		job = {}
		job['id'] = parts[0].strip
		job['state'] = parts[1].strip
		job['account'] = parts[2].strip
		job['user'] = parts[3].strip
		job['runtime'] = parseRuntime(parts[4].strip)
		job['runtime_str'] = parts[4].strip
		job['alloc_cpus'] = parts[5].strip.to_i
		job['req_mem'] = parts[6].strip.to_i * 1024 * 1024 # given in MB from sacct
		job['req_mem_str'] = parts[6].strip
		job['alloc_nodes'] = parts[7].strip.to_i
		job['partition'] = parts[8].strip
		job['total_cpu'] = 0
		job['max_rss'] = 0
		job['steps'] = []

		# Get all associated job steps
		step_sacct_output = `sacct -j #{job['id']} -o JobID,MaxRSS,TotalCPU,NTasks --noheader --parsable2 --noconvert`

		step_sacct_output.each_line do |step_line|
			step_parts = step_line.split("|")

			step = {}
			step['id'] = step_parts[0]
			step['max_rss'] = step_parts[1].to_i * step_parts[3].to_i # MaxRSS * NTasks
			step['total_cpu'] = parseRuntime(step_parts[2])

			if step['id'] == job['id'] ; then
                	        job['total_cpu'] = step['total_cpu']
				next
	                end

			job['max_rss'] = step['max_rss'] if step['max_rss'] > job['max_rss']
		end

		job['cpu_eff'] = ((job['total_cpu'].to_f / (job['runtime'] * job['alloc_cpus']).to_f) * 100).round(2)
		job['max_mem_util'] = ((job['max_rss'].to_f / job['req_mem'].to_f) * 100).round(2)

		# Catch NaN / negative values
		job['cpu_eff'] = 0.0 if job['cpu_eff'].nan? or job['cpu_eff'] < 0 or job['cpu_eff'].infinite?()
		job['max_mem_util'] = 0.0 if job['max_mem_util'].nan? or job['max_mem_util'] < 0 or job['max_mem_util'].infinite?()

		completed_jobs << job

	end

	return completed_jobs
end