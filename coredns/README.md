# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Install
```
$ kubectl apply -f .
```

Edit the coredns config to add:
...
    volumes:
        ...
        - name: coredns-zone-volume
          configMap:
            name: coredns-zones
...
        volumeMounts:
        ...
        - mountPath: "/etc/coredns/zones"
            name: coredns-zone-volume

## Validate
From a worker node:
```
$ nslookup node01.home.lab
```
