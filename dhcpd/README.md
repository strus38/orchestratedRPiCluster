# DHPCD

Provides DHCP services for the RPIs cluster and services.
Note: at this stage this is not needed since we have the laptop running a DHCP server for the same subnet, and we cannot limit Windows ISC DHPC to a range of a subnet.

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