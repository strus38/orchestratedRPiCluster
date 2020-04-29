# Orchestrated RPi cluster

## Objective
Build a HPC home-lab based on RPIs managed by a K8S cluster on a laptop

**Status: work in progress**

## Hardware
- A laptop/desktop to run the K8S cluster (CPU: VT-x capable CPU, RAM: min: 8GB memory, max: no limits)
    * Linux or Windows 10 PRO (not tested with family, but should work)
    * Vagrant
    * Virtualbox

- As many as RPIs you have from RPi2 to RPi4
- 1 switch
- Some RJ45 cables
- 1 multi-USB power station
- Optionally 1 External DD or a NAS to have some NFS storage capacity (without, the storage node SD card will be enough)

## Building the RPi cluster
- build a stand or buy a RPis cluster case
- flash all the RPi SD with the latest Raspbian version
- connect all power/switch ports
- power up 

## Roles
- RPIs[01]: storage node with NFS server - how to install (will be writen later)
- RPis[02-0x]: compute nodes  - how to install (will be writen later)
- Laptop: K8S server providing basic cluster services:
    * SLURM controller (in progress)
    * DHCPD server (in progress)
    * DNS server (in progress)
    * PXE boot (not yet implemented)
    * ... more to come
- K8S services:
    * grafana & prometheus monitoring
    * K8S dashboard
    * metallb
    * (more to come)

## What's next

### Power up the K8S cluster
$ vagrant up
$ vagrant status
$ vagrant ssh xxx
then manually update /etc/resolv.conf with the eth1 value (will be fixed soon)