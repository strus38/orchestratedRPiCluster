 # Metallb deployment

 ## Install
 ```
 helm install metallb stable/metallb -n kube-system
 kubectl apply -f metallb-config.yml
```
 ## Test metallb
 ```
 kubectl apply -f nginx.yaml
 kubectl get svc nginx
 ```
 Check that the EXTERNAL_IP is assigned

 Note: <pending> means something wrong with the subnet used in Metallb vs Vagrant VMs eth1 assigned subnet