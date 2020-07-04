# Keycloack service

## install
```
kubectl create secret generic realm-secret --from-file=realm.json
helm install keycloak codecentric/keycloak --version 8.2.2 -f kcvalues.yaml -n kube-system
```