#!/usr/bin/env bash
# kuberverse k8s lab provisioner

KVMSG=$1
NODE=$2
NODE_HOST_IP=$((220+NODE))
POD_CIDR=$3
API_ADV_ADDRESS=$4

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Joining Kubernetes Cluster"
echo "********** $KVMSG ->> Worker Node $NODE"
echo "********** $KVMSG ->> kv-worker-$NODE"

# Extract and execute the kubeadm join command from the exported file
$(cat /vagrant/kubeadm-init.out | grep -A 2 "kubeadm join" | sed -e 's/^[ \t]*//' | tr '\n' ' ' | sed -e 's/ \\ / /g')
echo KUBELET_EXTRA_ARGS=--node-ip=10.0.0.$NODE_HOST_IP > /etc/default/kubelet

# update the DNS resolution
sed -i 's/^#DNS=/DNS=10.0.0.20/' /etc/systemd/resolved.conf
sed -i 's/^#FallbackDNS=/FallbackDNS=10.96.0.10/' /etc/systemd/resolved.conf
sed -i 's/^#Domains=/Domains=default.svc.cluster.local svc.cluster.local home.lab' /etc/systemd/resolved.conf
rm -f /etc/resolv.conf
echo "nameserver 10.0.0.20" > /etc/resolv.conf
echo "nameserver 10.96.0.10" >> /etc/resolv.conf
echo "search default.svc.cluster.local svc.cluster.local home.lab" >> /etc/resolv.conf
echo "options eth1"
#service systemd-resolved restart