# Ansible playbook to deploy node exporter in RPi nodes

## install

* Install mitogen: https://networkgenomics.com/try/mitogen-0.2.9.tar.gz

## Run

* export env var
```
export NETBOX_API_KEY=xxx
```

* View your inventory
```
ansible-inventory -v --list -i inventory.yml
```

* Execute the playbooks
```
ansible-playbook rpi-setup.yaml
```