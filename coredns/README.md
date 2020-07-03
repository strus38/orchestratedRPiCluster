# CoreDNS service

Provides the DNS for RPi nodes and for Services

## Install
```
$ kubectl apply -f .
```

## Customize the default deployment

* Update the coredns ConfigMap, by adding:
```
auto {
    directory /etc/coredns/zones
}
```

* Edit the coredns deployment file to add:
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
