# RPi Cluster setup

## Overview
The RPis cluster is made of:
- Storage node to provide NFS server capility (may be moved to K8S cluster)
- Compute nodes (CPU capacity depends on the RPis version: 1 or 4 CPUs)

Notes:
- All RPIs nodes must have DHCP coming from the K8S cluster DHCPD service
- All RPIs hostname are provided by CoreDNS service of K8S cluster

## Setup


## Test config


## Add RPis nodes monitoring
- node_exporter is used to expose compute node metrics to the Prometheus service.
Install is done using the playbook found in this directory.
Check the last release: https://github.com/prometheus/node_exporter/releases/tag and update the playbook accordingly.