# Docker registry

## Prepare and configure
!! Optionnal: This will overwrite the values set ... so do it only if you know what you are doing.
```
helm inspect values stable/docker-registry > registryvalues.yaml
```

## Install
```
helm install docker-registry stable/docker-registry -n rack01 -f registryvalues.yaml
kubectl apply -f registryui.yaml -n rack01
```
