# SLURM Controller hosted in K8S

Work in progress

## Install
```
kubectl apply -f slurm-k8s.yaml
```
Once deployed, you must manually copy the munge.key to the RPis nodes
```
$ kubectl get pods -n slurm-ns
NAME                     READY   STATUS    RESTARTS   AGE
slurm-745f46bd9b-26nms   1/1     Running   0          4m28s
```

Then, in each rpi, you have to copy the new munge.key file ... trying to see how to automate that.
```
<pi_node>$ sudo cp /clusterfs/munge.key /etc/munge/munge.key
```

## Dependencies
CentOs7 SLURM Controller: strusfr/docker-unbuntu1604-slurmctld:latest

## Verify
Depending on the status of your nodes... here is an example whith different node status

```
$ kubectl get pods -n slurm-ns
NAME                     READY   STATUS    RESTARTS   AGE
slurm-745f46bd9b-26nms   1/1     Running   0          4m28s

$ kubectl exec slurm-745f46bd9b-26nms -n slurm-ns -- sinfo
PARTITION AVAIL  TIMELIMIT  NODES  STATE NODELIST
allnodes*    up   infinite      1   unk* node05
allnodes*    up   infinite      1  drain node03
allnodes*    up   infinite      2   idle node[02,04]
```