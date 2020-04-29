# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Prepare and configure
$ helm inspect values stable/coredns > coredns/corednsvalues.yaml

## Install
$ kubectl create namespace coredns
$ helm install --name coredns --namespace=kube-system stable/coredns -n coredns
