# RPi Cluster setup

## Overview
The RPis cluster is made of:
- Storage node to provide NFS server capility (may be moved to K8S cluster)
- Compute nodes (CPU capacity depends on the RPis version: 1 or 4 CPUs)

The goal of this repository is to automate:
- The installation and configuration of all the software necessary on the compute nodes
- The installation configuration of the node storage
- Install and configure the compute nodes as SLURM clients
- A deployment file to run a POD which is able to run ansible-playbooks directly from the K8S cluster and targetting the nodes, so we can easily update some config afterwards.

## Setup
<TODO>
- ansible directory: contains the roles and playbooks to configure the nodes
  - roles: the roles
  - pb-rpi.yaml: main playbook to configure all the RPIs nodes (Compute and storage nodes)

## Test config
<TODO>

## Add RPis nodes monitoring
- node_exporter is used to expose compute node metrics to the Prometheus service.
Install is done using the playbook found in this directory.
Check the last release: https://github.com/prometheus/node_exporter/releases/tag and update the playbook accordingly.
