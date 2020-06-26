# Cert manager

## Prepare
helm inspect values jetstack/cert-manager > cert-manager.values

## Installation
```
## IMPORTANT: you MUST install the cert-manager CRDs **before** installing the
kubectl apply --validate=false -f cert-manager.crds.yaml

## Install the cert-manager helm chart
$ helm install cert-manager jetstack/cert-manager -n cert-manager --version v0.15.0

## After all is running, generate self-signed certs
kubectl apply -f issuer.yaml
```

## Tweak you can apply after deployment
```

```