# K8S dashboard

## Install
```
kubectl apply -f *
```

## Get access token
```
kubectl create serviceaccount dashboard-admin-sa
kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
kubectl get secrets -n kubernetes-dashboard
kubectl describe secret dashboard-admin-sa-token-xxx -n kubernetes-dashboard
```