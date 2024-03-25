
# Slurm Job Exporter
Service written in Ruby to collect slurm job statistics and export them in Prometheus style metrics via a simple `Net::HTTP::Server` .

Example metrics:
```
slurm_job_meta{jobid="12345678", state="COMPLETED", partition="partition1", account="default", user="user1", nodes="1", cpus="10", memory="107374182400", cpu_eff="0.83", mem_util="0.05", runtime="00:00:48"} 1
slurm_job_cpu_eff{jobid="12345678", account="default", user="user1"} 0.83
slurm_job_mem_util{jobid="12345678", account="default", user="user1"} 0.05
```

## Prerequisites
- Git
- Ruby (tested with v2.7.1)
- Ruby `bundle`

## Installation
Clone this git repository and checkout the desired branch / release.
```
git clone
git checkout <branch/release>
```

Run the installation script. The installation will install to `/opt/slurm-job-exporter` - if you wish to install elsewhere you will need to update the install script and service file as appropriate.
```
cd slurm-job-exporter
bash install.sh
```

If your Ruby binary is not in the default path `/bin/ruby`, update this to the correct path.
```
vim /usr/lib/systemd/system/power-exporter.service
systemctl daemon-reload
```
Install the required Ruby gems.
```
cd /opt/slurm-job-exporter
/path/to/bundle install
```

Configure `/opt/slurm-job-exporter/etc/config.yaml` - an example configuration file is provided with a brief explanation of the various configuration parameters.

Minimal configuration example:
```
exporter:
  port: 9107
  log: log/slurm-job-exporter.log
```

Enable and start the service
```
systemctl daemon-reload
systemctl enable --now slurm-job-exporter
```

## Known Issues / Future Enhancements
Currently the exporter is configured to collect Slurm job statistics for the last 5 minutes each time it is scraped. This has multiple issues:

- If the scrape interval is longer than this then jobs are likely to be missed.
- If the exporter is scraped by multiple instances then this could add unnecessary load to the scheduler.

Future work would look to rewrite the exporter into two separate threads:
- A collector, responsible for collecting and caching the jobs metrics.
- An exporter, responsible for exposing the latest cached jobs metrics.
