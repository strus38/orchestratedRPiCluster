# TFTP server

## Install
```
$ kubectl apply -f tftp-hpa.yaml
$ kubectl get svc -n ftpsvc
$ kubectl get pods -n ftpsvc
```

## Validate
From one of the RPis, test the connection
```
$ nc -z -v -u 192.168.1.199 69
Connection to 192.168.1.199 69 port [udp/tftp] succeeded!

tftp
(to) 192.168.1.199
tftp> status
Connected to 192.168.1.199.
Mode: netascii Verbose: off Tracing: off Literal: off
Rexmt-interval: 5 seconds, Max-timeout: 25 seconds
tftp> get ls
Transfer timed out.
```
