# CoreDNS service

Provides the DNS for RPi nodes and for Services

Note: no need to deploy a special CoreDNS chart, since by Default, coredns is deployed already.

$ kubectl describe configmap config -n kube-system
apiServer:
  extraArgs:
    authorization-mode: Node,RBAC
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta2
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns:
  type: CoreDNS
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: k8s.gcr.io
kind: ClusterConfiguration
kubernetesVersion: v1.18.2
networking:
  dnsDomain: cluster.local
  podSubnet: 172.18.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}

$ kubectl describe configmap coredns -n kube-system
Name:         coredns
Namespace:    kube-system
Labels:       <none>
Annotations:  <none>

Data
====
Corefile:
----
.:53 {
    errors
    health {
       lameduck 5s
    }
    ready
    kubernetes cluster.local in-addr.arpa ip6.arpa {
       pods insecure
       fallthrough in-addr.arpa ip6.arpa
       ttl 30
    }
    prometheus :9153
    forward . /etc/resolv.conf
    cache 30
    loop
    reload
    loadbalance
}

Events:  <none>
## Debug
$ kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml                                                                        

$ kubectl get pods dnsutils
NAME       READY   STATUS    RESTARTS   AGE
dnsutils   1/1     Running   0          3m12s

Result is sotmething like:
$ kubectl exec -ti dnsutils -- nslookup kubernetes.default
Server:    10.0.0.10
Address 1: 10.0.0.10

Name:      kubernetes.default
Address 1: 10.0.0.1
