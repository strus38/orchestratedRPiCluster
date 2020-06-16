#!/usr/bin/env bash
# kuberverse k8s lab provisioner

KVMSG=$1
NODE=$2
POD_CIDR=$3
API_ADV_ADDRESS=$4
NODE_HOST_IP=$((10+NODE))

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Initializing Kubernetes Cluster"
echo "********** $KVMSG ->> Master Node $NODE"
echo "********** $KVMSG ->> kv-master-$NODE"
kubeadm init --pod-network-cidr $POD_CIDR --apiserver-advertise-address $API_ADV_ADDRESS | tee /vagrant/kubeadm-init.out
# optionnaly can add: --kubernetes-version=v1.18.3
echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Configuring Kubernetes Cluster Environment"
echo "********** $KVMSG"
echo "********** $KVMSG"
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config
mkdir -p /root/.kube
cp -i /etc/kubernetes/admin.conf /root/.kube/config

#Configure the Calico Network Plugin
echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Configuring Kubernetes Cluster Calico Networking"
echo "********** $KVMSG ->> Downloading Calico YAML File"
echo "********** $KVMSG"
echo "********** $KVMSG"
wget -q https://raw.githubusercontent.com/strus38/orchestratedRPiCluster/master/calico.yaml -O /tmp/calico-default.yaml
sed "s+10.0.0.0/16+$POD_CIDR+g" /tmp/calico-default.yaml > /tmp/calico-defined.yaml

echo "********** $KVMSG ->> Applying Calico YAML File"
echo "********** $KVMSG"
echo "********** $KVMSG"
kubectl apply -f /tmp/calico-defined.yaml
rm /tmp/calico-default.yaml /tmp/calico-defined.yaml
echo KUBELET_EXTRA_ARGS=--node-ip=10.0.0.2$NODE_HOST_IP > /etc/default/kubelet
service kubelet restart

# update the DNS resolution
#sed -i 's/^#DNS=/DNS=10.96.0.10/' /etc/systemd/resolved.conf
#service systemd-resolved restart

#systemctl stop systemd-resolved
#systemctl stop systemd-networkd
#systemctl disable systemd-resolved
#systemctl disable systemd-networkd

#echo "nameserver 10.0.0.20" > /etc/resolv.conf
#echo "nameserver 10.96.0.10" > /etc/resolv.conf
#echo "search default.svc.cluster.local svc.cluster.local home.lab" >> /etc/resolv.conf
#echo "options ndots:5" >> /etc/resolv.conf