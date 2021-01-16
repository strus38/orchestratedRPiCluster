Discourse
=========

helm repo add bitnami https://charts.bitnami.com/bitnami

helm inspect values bitnami/discourse > discourse_values.yaml

helm install discourse bitnami/discourse -f discourse_values.yaml -n kube-system