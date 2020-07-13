# TFTP server

## Install
```
$ kubectl apply -f tftp-hpa.yaml
```

## Validate
From one of the RPis, test the connection
```
$ nc -z -v -u 10.0.0.12 69
Connection to 10.0.0.12 69 port [udp/tftp] succeeded!

tftp
(to) 10.0.0.12
tftp> status
Connected to 10.0.0.12.
Mode: netascii Verbose: off Tracing: off Literal: off
Rexmt-interval: 5 seconds, Max-timeout: 25 seconds
tftp> get ls
Transfer timed out.
```
