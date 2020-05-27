# NFS client

## Install

helm install nfs-client stable/nfs-client-provisioner -n kube-system --set nfs.server=10.0.0.2 --set nfs.path=/mnt/usb