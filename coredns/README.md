# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Install
```
$ kubectl apply -f .
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
