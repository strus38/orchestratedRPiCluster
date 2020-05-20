# Install all apps related to monitoring in the monitoring namespace

## Prepare
```
kubectl apply -f monitoring-ns.yml
```

## Loadbalancer
Metallb is used to provide external access to those apps

# Prometheus

## Prepare
!! Optionnal: This will overwrite the values set ... so do it only if you know what you are doing.
```
helm inspect values stable/prometheus > prometheus.values
```

## Install
* Install the prometeus server
```
helm install prometheus stable/prometheus -n monitoring -f .\prometheus\prometheus.values
```

* Install the kube-state-metric
```
kubectl apply -f .\kubestatemetrics\.
```

## Add RPi node
Releases: https://github.com/prometheus/node_exporter/releases
RPi 3/4: wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv7.tar.gz
RPi 2: wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv6.tar.gz

# Grafana

## Prepare
!! Optionnal: This will overwrite the values set ... so do it only if you know what you are doing.
```
helm inspect values stable/grafana > .\grafana\grafanavalues.yaml
```

## Install
* Install the server part
```
kubectl apply -f ./grafana/grafanaconfig.yaml
helm install grafana stable/grafana -f .\grafana\grafanavalues.yaml --namespace monitoring
```

* Add the dashboard you want :-) ... some provided in this repo.s

## Retrieve the password
```
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}"
```
Then use whatever you want to decode base64 (online or cmd on a linux)
