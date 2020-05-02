# SFTP Server

## Prepare
Copy your local ssh key into a configmap. Only 1 user is available: pxe
```
$ kubectl create configmap sftp-public-keys --from-file C:\Users\miamore\.ssh\id_rsa.pub -n coredns
```

## Install
```
kubectl install -f sftpserver/yaml
kubectl get svc -n coredns
<retrieve the external_ip of the sftp server>
```

## Validate
Push a local file into the server:
```
sftp -P22 pxe@<external_ip>
    Connected to pxe@<external_ip>
sftp> cd incoming
sftp> put sftpserver.yaml
Uploading sftpserver.yaml to /incoming/sftpserver.yaml
sftpserver.yaml       100% 1923   965.0KB/s   00:00
sftp> ls
sftpserver.yaml
sftp> exit
```