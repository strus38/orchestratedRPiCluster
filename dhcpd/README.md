# DHPCD

Provides DHCP services for the RPIs cluster and services.
Note: should only be deployed if not using another DHCP server in 192.168.1.0/24 subnet

## Prepare & Configure
```
helm repo add pnnl-miscscripts https://pnnl-miscscripts.github.io/charts
helm inspect values pnnl-miscscripts/dhcpd > dhcpd/dhpcdvalues.yaml
```

Update the RPIs node names that will be managed

## Install
```
kubectl create namespace dhcpd
helm install dhpd pnnl-miscscripts/dhcpd -f dhcpdvalues.yaml -n dhcpd
```