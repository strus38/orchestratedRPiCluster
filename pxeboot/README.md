# PXE Boot

## Prepare
```
kubectl create namespace provision
helm inspect values pnnl-miscscripts/pixiecore-simpleconfig --version 0.1.3 > pxevalues.yaml
```

## Install
```
helm install pixiecore pnnlmiscscripts/pixiecore-simpleconfig -n provision -f pxevalues.yaml
```