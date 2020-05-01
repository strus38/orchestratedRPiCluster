# K8S dashboard

## Install
kubectl apply -f .\k8sdashboard\dashboard.yml

## Get access token
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
kubectl get secrets
kubectl describe secret dashboard-admin-sa-token-kw7vn
