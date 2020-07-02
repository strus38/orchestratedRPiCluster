# Netbox install

## Deploy

```
kubectl apply -f . -n kube-system
```

## Populate netbox

* Update the file config/site.yaml to match your configuration following the example given.
* Put the info in the config/config.py (normally only the token should be updated)
Then, run:
```
$ python3 config/netbox_init.py
```

## Install agent

```
Connect to the vagrant VMs
$ vagrant ssh kv-xxxx
$ netbox_client -c nbagent.yaml --register
```