# Orchestrated RPi cluster

## Objective
Build a HPC home-lab based on RPIs managed by a K8S cluster on a laptop

Grafana Cluster Status
![K8S Cluster view](imgs/grafClusterStatus.PNG)

Grafana RPI Cluster Status
![RPIs Cluster view](imgs/grafrpisstatus.PNG)

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
    * Docker registry
    * ... more to come
- K8S services:
    * grafana & prometheus monitoring
    * K8S dashboard
    * metallb
    * ... more to come

## What's next

Steps to deploy:

1- Power up the K8S cluster on your laptop
By default: 1 Master and 3 workers
Update the Vagrantfile to match your subnets.
```
$ vagrant up
```
Then, wait 1h or so depending on the speed of your internet speed.
```
$ vagrant status
$ vagrant ssh xxx
```
then manually update /etc/resolv.conf with the eth1 value (will be fixed soon)
```
$ cat .kube/config
```
Save the content to put in on your laptop %HOME%/.kube/config. This will allow kubectl actions from your powershell.

Check that the kubelet config is set correctly (on all masters and workers)
```
sudo cat /etc/default/kubelet
KUBELET_EXTRA_ARGS=--node-ip=<eth1 ip>
```
if not, fix it, and restart kubelet
```
sudo service kubelet restart
```

From your laptop, check the status of your K8S cluster:
```
$ kubectl get nodes
NAME          STATUS     ROLES    AGE     VERSION
kv-master-0   Ready      master   85m     v1.18.2
kv-worker-0   Ready      <none>   63m     v1.18.2
kv-worker-1   Ready      <none>   36m     v1.18.2
kv-worker-2   NotReady   <none>   6m49s   v1.18.2
```

2- Deploy Metallb
```
$ cd metallb
```
Read the README file for details

3- Deploy k8s dashboard
```
$ cd k8sdashboard
```
Read the README file for details

4- Deploy coredns
```
$ cd coredns
```
Read the README file for details

5- Deploy registry
```
$ cd registry
```
Read the README file for details

6- Deploy monitoring
```
$ cd monitoring
```
Read the README file for details

7- Deploy dhcpd
```
$ cd dhcpd
```
Read the README file for details

8- Deploy slurmctl
```
$ cd slutmctld
```
Read the README file for details

9- Finish the config of your RPis
```
$ cd rpicluster
```
Read the README file for details

Launch your SLURM jobs :-)