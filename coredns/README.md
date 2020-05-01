# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Prepare
```
$ kubectl create namespace coredns
```

## Install
```
$ kubectl apply -f .\coredns-configmap.yaml
configmap/coredns-config created
$ kubectl apply -f .\lab-configmap.yaml  configmap/coredns-zones created
$ kubectl apply -f .\lab-corednstcp.yaml
service/kube-dns-tcp created
$ kubectl apply -f .\lab-corednsudp.yaml
service/kube-dns-udp created
```

## Validate
From your powershell
```
nslookup
> server 192.168.1.180
> node01.home.lab
> node02.home.lab
> node03.home.lab
> node04.home.lab
```
