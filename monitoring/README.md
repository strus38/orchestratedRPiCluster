# Install all apps related to monitoring in the monitoring namespace

## Prepare
kubectl apply -f namespace.yml

## Loadbalancer
Metallb is used to provide external access to those apps

# Prometheus

## Install
helm inspect values stable/prometheus > /tmp/prometheus.values
helm install prometheus stable/prometheus -n monitoring -f .\monitoring\prometheus.values

## Add RPi node
Releases: https://github.com/prometheus/node_exporter/releases
RPi 3/4: wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv7.tar.gz
RPi 2: wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-armv6.tar.gz

# Grafana

## Prepare
helm inspect values stable/grafana > .\monitoring\grafanavalues.yaml

## sidecar
kubectl apply -f .\monitoring\grafanaconfig.yaml

## Change to LoadBalancer
helm install grafana stable/grafana -f .\monitoring\grafanavalues.yaml --namespace monitoring

## Retrieve the password
kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# K8S dashboard

## Install
kubectl apply -f .\monitoring\dashboard.yml

## Get access token
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
kubectl get secrets
kubectl describe secret dashboard-admin-sa-token-kw7vn
