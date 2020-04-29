 # Metallb deployment

 ## Install
 helm install metallb stable/metallb --set rbac.create=false --namespace kube-system

 ## Test metallb
 kubectl apply -f test.yaml
 Check that the EXTERNAL_IP is assigned

 Note: <pending> means something wrong with the subnet used in Metallb vs Vagrant VMs eth1 assigned subnet