#!/usr/bin/env bash
# kuberverse k8s lab provisioner

#variable definitions
KVMSG=$1

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Adding Kubernetes and Docker-CE Repo"
echo "********** $KVMSG"
echo "********** $KVMSG"
### Install packages to allow apt to use a repository over HTTPS
apt-get update -y && apt-get install -y apt-transport-https ca-certificates curl software-properties-common

### Add Kubernetes GPG key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

### Kubernetes Repo
echo "deb  http://apt.kubernetes.io/  kubernetes-xenial  main" > /etc/apt/sources.list.d/kubernetes.list

### Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

### Add Docker apt repository.
add-apt-repository \
  "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) \
  stable"

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Updating Repositories"
echo "********** $KVMSG"
echo "********** $KVMSG"
apt-get update

echo "********** $KVMSG"
echo "********** $KVMSG"
echo "********** $KVMSG ->> Installing Required & Recommended Packages"
echo "********** $KVMSG"
echo "********** $KVMSG"
apt-get install -y chrony avahi-daemon libnss-mdns traceroute htop httpie bash-completion docker-ce=5:19.03.14~3-0~ubuntu-focal kubeadm=1.20.1-00 kubelet=1.19.5-00 kubectl=1.20.1-00 python3 python3-pip
pip3 install netbox-agent

# Setting time...
timedatectl set-timezone Europe/Paris

cat > /etc/qualification <<EOF
DATACENTER: home.lab
EOF

cat > /root/nbagent.yaml <<EOF
# Netbox configuration
netbox:
  url: 'https://netbox.home.lab'
  token: 0123456789abcdef0123456789abcdef01234567
# Network configuration
network:
  # Regex to ignore interfaces
  ignore_interfaces: "(dummy.*|tunl.*)"
  # Regex to ignore IP addresses
  ignore_ips: (127\.0\.0\..*)
  # enable auto-cabling by parsing LLDP answers
  lldp: false
## Enable virtual machine support
virtual:
  # not mandatory, can be guessed
  enabled: true
  # see https://netbox.company.com/virtualization/clusters/
  cluster_name: K8S cluster
# Enable datacenter location feature in Netbox
datacenter_location:
 driver: "cmd:cat /etc/qualification | tr [a-z] [A-Z]"
 regex: "DATACENTER: (?P<datacenter>[A-Za-z0-9]+)"
# driver: 'cmd: lldpctl'
# regex: 'SysName: .*\.([A-Za-z0-9]+)'
#
# driver: "file:/tmp/datacenter"
# regex: "(.*)"

# Enable rack location feature in Netbox
rack_location:
# driver: 'cmd:lldpctl'
# match SysName: sw-dist-a1.dc42
# regex: 'SysName:[ ]+[A-Za-z]+-[A-Za-z]+-([A-Za-z0-9]+)'
#
# driver: "file:/tmp/datacenter"
# regex: "(.*)"

# Enable local inventory reporting
inventory: true
EOF

cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "insecure-registries": ["https://registry.home.lab","https://harbor.home.lab"],
  "registry-mirrors": ["https://docker.io","https://quay.io"],
  "storage-driver": "overlay2"
}
EOF

mkdir -p /etc/systemd/system/docker.service.d

# Restart docker.
systemctl daemon-reload
systemctl restart docker

# Set the registry common script
cat > /root/add2reg.sh <<EOF
docker login --username=admin --password=Harbor12345 https://harbor.home.lab
for i in \$(docker images --format="{{.Repository}}:{{.Tag}}" | grep -v home.lab); do 
  docker tag \$i harbor.home.lab/library/\$i
  docker push harbor.home.lab/library/\$i
done
EOF
chmod 755 /root/add2reg.sh
