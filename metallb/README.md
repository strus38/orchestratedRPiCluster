# Metallb deployment

## Prepare
Add the Helm repo:


## Install with Helm
```
helm install metallb stable/metallb -n kube-system
kubectl apply -f metallb-config.yml
```

## (Alternative) install without Helm
```
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml
# On first install only
kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
```
## Test metallb
```
kubectl apply -f nginx.yaml
kubectl get svc nginx
```
Check that the EXTERNAL_IP is assigned

 Note: <pending> means something wrong with the subnet used in Metallb vs Vagrant VMs eth1 assigned subnet