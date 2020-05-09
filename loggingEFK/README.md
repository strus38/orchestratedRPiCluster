# Logging with EFK stack (ElasticSearch/Fluentd/Kibana)

## Installation instructions

```
$ kubectl create namespace logging
$ helm repo add elastic https://helm.elastic.co
```
Install Elastic Search version 7.6.2 with 10GB sized volumes in the logging namespace.
```
$ helm install elasticsearch elastic/elasticsearch --version 7.6.2 --namespace logging  --set volumeClaimTemplate.resources.requests.storage=10Gi --set replicas=1 --set esJavaOpts="-Xmx512m -Xms512m" --set resources.requests.cpu=400m --set resources.requests.memory=1G

... wait ... and optionaly for debug

$ kubectl port-forward svc/elasticsearch-master 9200
```
Install Kibana from repo (note it takes about five minutes for this to start up).
```
helm install kibana elastic/kibana --version 7.6.2 -n logging --set elasticsearchHosts="http://elasticsearch-master.logging.svc.cluster.local:9200" --set service.type=LoadBalancer --set resources.requests.cpu=200m --set resources.requests.memory=512Mi
```
Install Fluent-bit from stable repo
```
helm install fluent-bit stable/fluent-bit -n logging --set backend.type=es --set  backend.es.host="elasticsearch-master.logging.svc.cluster.local" --set filter.mergeJSONLog=true --set extraEntries.filter="Merge_Log_Key logfield" --set backend.es.retry_limit=5 --set resources.requests.cpu=100m --set resources.requests.memory=64Mi
```
Install a data pipeline
```
$ helm install metricbeat elastic/metricbeat -n logging

... wait again since it may take some time for those metrics to reach Kibana
```

Configure the index based on metricbeat in Kibana.

![Create index view](../imgs/kibanaIndexCreate.PNG)


## Validation
Check that all pods are running fine (it takes quite a while at each step because of cpu/memory limits put in place)
```
$ kubectl get pods -n logging
NAME                                             READY   STATUS              RESTARTS   AGE
elasticsearch-master-0                           1/1     Running             0          73m
fluent-bit-6wdt6                                 1/1     Running             0          18m
fluent-bit-9smdd                                 1/1     Running             0          18m
fluent-bit-nlwk2                                 1/1     Running             0          18m
kibana-kibana-7f7b86cc77-45h2q                   1/1     Running             1          60m
metricbeat-kube-state-metrics-6f88454b98-x2r8h   1/1     Running             0          3m3s
metricbeat-metricbeat-28q6h                      1/1     Running             0          3m3s
metricbeat-metricbeat-8jg4x                      1/1     Running             0          3m3s
metricbeat-metricbeat-9j4l7                      1/1     Running             0          3m3s
metricbeat-metricbeat-metrics-5d848586bd-qstbd   1/1     Running             0          3m3s
```

Then access the Kibana dashboard :-)


