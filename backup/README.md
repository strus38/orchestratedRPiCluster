Backup solution
===============

Based on Velero

helm inspect values vmware-tanzu/velero > velero-values.yaml

helm install vmware-tanzu/velero \
--namespace <YOUR NAMESPACE> \
--create-namespace \
--set-file credentials.secretContents.cloud=<FULL PATH TO FILE> \
--set configuration.provider=<PROVIDER NAME> \
--set configuration.backupStorageLocation.name=<BACKUP STORAGE LOCATION NAME> \
--set configuration.backupStorageLocation.bucket=<BUCKET NAME> \
--set configuration.backupStorageLocation.config.region=<REGION> \
--set configuration.volumeSnapshotLocation.name=<VOLUME SNAPSHOT LOCATION NAME> \
--set configuration.volumeSnapshotLocation.config.region=<REGION> \
--set initContainers[0].name=velero-plugin-for-<PROVIDER NAME> \
--set initContainers[0].image=velero/velero-plugin-for-<PROVIDER NAME>:<PROVIDER PLUGIN TAG> \
--set initContainers[0].volumeMounts[0].mountPath=/target \
--set initContainers[0].volumeMounts[0].name=plugins \
--generate-name