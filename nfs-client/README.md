# NFS client

## Install

helm install nfs-client stable/nfs-client-provisioner --set nfs.server=node01.home.lab --set nfs.path=/mnt/usb6 --set storageClass.name=nfs-dyn