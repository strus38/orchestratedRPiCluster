# Cert manager

## Prepare
helm inspect values jetstack/cert-manager > cert-manager.values

## Installation
```
## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
kubectl apply --validate=false -f cert-manager.crds.yaml

# no more needed $ kubectl label namespace kube-system certmanager.k8s.io/disable-validation="true"

## Install the cert-manager helm chart
$ helm install cert-manager jetstack/cert-manager -n cert-manager --version v0.15.0

## After all is running, generate self-signed certs
kubectl apply -f issuer.yaml
```