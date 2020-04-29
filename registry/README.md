# Docker registry

## Prepare and configure
helm inspect values stable/docker-registry > registry/registryvalues.yaml

## Install
kubectl create namespace registry
helm install stable/docker-registry -n registry -f registryvalues.yaml

## Post install
export POD_NAME=$(kubectl get pods --namespace registry -l "app=docker-registry,release=registry" -o jsonpath="{.items[0].metadata.name}")
kubectl -n registry port-forward $POD_NAME 8080:5000