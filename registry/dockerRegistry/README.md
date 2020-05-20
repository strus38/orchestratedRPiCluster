# Docker registry

## Prepare and configure
!! Optionnal: This will overwrite the values set ... so do it only if you know what you are doing.
```
helm inspect values stable/docker-registry > registryvalues.yaml
```

## Install
```
helm install registry stable/docker-registry -n registry -f registryvalues.yaml
kubectl apply -f registryui.yaml -n registry
```

## Post install
```
export POD_NAME=$(kubectl get pods --namespace registry -l "app=docker-registry,release=registry" -o jsonpath="{.items[0].metadata.name}")
kubectl -n registry port-forward $POD_NAME 8080:5000
```