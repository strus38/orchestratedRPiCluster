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

# Make sure time is sync to master node
cat > /etc/chrony/chrony.conf <<EOF
server 10.0.0.210 prefer iburst
# This directive specify the location of the file containing ID/key pairs for
# NTP authentication.
keyfile /etc/chrony/chrony.keys

# This directive specify the file into which chronyd will store the rate
# information.
driftfile /var/lib/chrony/chrony.drift

# Uncomment the following line to turn logging on.
#log tracking measurements statistics

# Log files location.
logdir /var/log/chrony

# Stop bad estimates upsetting machine clock.
maxupdateskew 100.0

# This directive enables kernel synchronisation (every 11 minutes) of the
# real-time clock. Note that it can’t be used along with the 'rtcfile' directive.
rtcsync

# Step the system clock instead of slewing it if the adjustment is larger than
# one second, but only in the first three clock updates.
makestep 1 3
cmdallow 10.0.0.0/16
EOF
service chrony restart