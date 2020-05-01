# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Prepare
```
$ kubectl create namespace coredns
$ kubectl apply -f .\coredns-configmap.yaml
configmap/coredns-config created
$ kubectl apply -f .\lab-configmap.yaml  configmap/coredns-zones created
$ kubectl apply -f .\lab-corednstcp.yaml
service/kube-dns-tcp created
$ kubectl apply -f .\lab-corednsudp.yaml
service/kube-dns-udp created
```