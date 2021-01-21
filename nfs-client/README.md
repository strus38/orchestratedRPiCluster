# NFS client

## Install
DEPRECATED - Jan 2021 - Replaced by nfs-subdir-external-provisioner
helm install nfs-client stable/nfs-client-provisioner --set storageClass.reclaimPolicy=Retain --set nfs.server=node01.home.lab --set nfs.path=/mnt/usb6 --set storageClass.name=nfs-dyn