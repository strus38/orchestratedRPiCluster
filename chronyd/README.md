# NTP server chronyd for the Cluster

## Installation
```
$ kubectl apply -f .
```

## Verifictation
Service is exposed on UDP on port 123
```
$ kubectl get svc -n chronyd
NAME      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)         AGE
chronyd   LoadBalancer   10.108.162.217   192.168.1.179   123:30117/UDP   9m27s
```
Check if the service is configured
```
$ kubectl exec -ti <chronypod> -- chronyc tracking
$ kubectl exec -ti <chronypod> -- chronyc sources
```