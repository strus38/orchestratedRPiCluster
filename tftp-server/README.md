# TFT Server

## Prepare
```
helm repo add pojntfx https://pojntfx.github.io/charts/
```

## Install
```
helm search repo pojntfx
helm install tftpd pojntfx/tftpdd -n coredns -f .\tftpdvalues.yaml
```