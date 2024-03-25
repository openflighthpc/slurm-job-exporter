#!/bin/bash

INSTALL_DEST=/opt/slurm-job-exporter

cp -R ./slurm-job-exporter /opt/slurm-job-exporter
cp ./slurm-job-exporter.service /usr/lib/systemd/system/slurm-job-exporter.service
