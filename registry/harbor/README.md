# Harbor registry

## Prepare

helm repo add harbor https://helm.goharbor.io

## install

helm install harbor harbor/harbor -n kube-system