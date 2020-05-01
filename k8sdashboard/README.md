# K8S dashboard

## Install
```
kubectl apply -f .\k8sdashboard\dashboard.yml
```

## Get access token
```
kubectl create serviceaccount dashboard-admin-sa -n kubernetes-dashboard
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa -n kubernetes-dashboard
kubectl get secrets -n kubernetes-dashboard
kubectl describe secret dashboard-admin-sa-token-xxx -n kubernetes-dashboard
```