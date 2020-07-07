#!/usr/bin/env bash
# kuberverse k8s lab provisioner

KVMSG=$1
NODE=$2
NODE_HOST_IP=$((220+NODE))
POD_CIDR=$3
API_ADV_ADDRESS=$4

echo "*** Enabling nf_nat_tftp"
modprobe nf_nat_tftp

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Joining Kubernetes Cluster"
echo "********** $KVMSG ->> Worker Node $NODE"
echo "********** $KVMSG ->> kv-worker-$NODE"

# Extract and execute the kubeadm join command from the exported file
$(cat /vagrant/kubeadm-init.out | grep -A 2 "kubeadm join" | sed -e 's/^[ \t]*//' | tr '\n' ' ' | sed -e 's/ \\ / /g')
echo KUBELET_EXTRA_ARGS=--node-ip=10.0.0.$NODE_HOST_IP > /etc/default/kubelet
service kubelet restart

# update the DNS resolution
sed -i 's/^#DNS=/DNS=10.96.0.10/' /etc/systemd/resolved.conf
sed -i 's/^#FallbackDNS=/FallbackDNS=10.0.0.20/' /etc/systemd/resolved.conf
service systemd-resolved restart
