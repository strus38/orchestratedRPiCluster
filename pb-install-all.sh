##
## Since running from Windows 10... ansible is not available and we have a chicken/egg issue :-)
##

function check_readiness {
    ready=false
    while  [ "$ready" = false ]; do
        ready=true
        for i in $(./kubectl get pods --all-namespaces |  grep  $1 | awk '{ print $3 }'); do
            IFS=/ read var1 var2 <<< $i
            if [ $var1 -ne $var2 ]; then
                ready=false
            fi
        done
        echo "Waiting for $1 to be ready: $ready"
        sleep 10s
    done
}

function create {
    vagrant up
}

function remove {
    vagrant destroy
}

function reset {
    ./kubectl config view --raw >/tmp/config
    export KUBECONFIG=/tmp/config
    ./kubectl delete ns kubernetes-dashboard --force
    ./kubectl delete ns rack01 --force
    ./kubectl delete ns rack02 --force
    ./kubectl delete ns cert-manager --force
    ./kubectl delete ns monitoring --force
    ./kubectl delete ns nginx-ingress --force
    ./kubectl delete ns kubevirt --force
}

function runcmds {
    KEYV=$1
    echo "-----"
    echo "### Checking Environment"
    if [ ! -f "kubectl" ]; then 
        echo "Installing kubectl"
        curl -fsSL https://storage.googleapis.com/kubernetes-release/release/v1.18.0/bin/windows/amd64/kubectl.exe -o kubectl.exe
        export PATH=$PATH:.
        ln -s kubectl.exe kubectl
    fi
    if [ ! -f "helm" ]; then 
        echo "Installing helm"
        if [ ! -f "get_helm.sh" ]; then 
            curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
        fi
        if [ ! -f "/usr/local/bin/helm" ]; then 
            ./get_helm.sh
            echo "Configure helm"
            # DEPRECATED helm repo add stableold https://kubernetes-charts.storage.googleapis.com/
            helm repo add pnnl-miscscripts https://pnnl-miscscripts.github.io/charts
            helm repo add pojntfx https://pojntfx.github.io/charts/
            helm repo add bitnami https://charts.bitnami.com/bitnami
            helm repo add akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/
            helm repo add elastic https://helm.elastic.co
            helm repo add jetstack https://charts.jetstack.io
            helm repo add codecentric https://codecentric.github.io/helm-charts
            helm repo add harbor https://helm.goharbor.io
            helm repo add sylabs https://charts.enterprise.sylabs.io
            helm repo add grafana https://grafana.github.io/helm-charts
            helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
            helm repo add stable https://charts.helm.sh/stable
            helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
            helm repo add vmware-tanzu https://vmware-tanzu.github.io/helm-charts
            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
            helm repo add gabibbo97 https://gabibbo97.github.io/charts/
        fi
    fi
    echo "### Testing binaries"
    export KUBECONFIG=/mnt/c/Users/miamore/.kube/config
    ./kubectl version
    helm version
    ./kubectl config view --raw >/tmp/config
    export KUBECONFIG=/tmp/config
    echo "###  Updating Helm repos"
    helm repo update
    echo "Environment READY"
    echo "-----"

    # if [ ! -f "/usr/local/bin/checkov" ]; then 
    #     echo "### Issuing security report"
    #     checkov -d . --framework kubernetes -o junitxml 2> checkov.results.xml
    #     junit2html checkov.results.xml > checkov.html
    # fi

    echo "### Starting configuration of all services..."
    ./kubectl get nodes
    echo "....Create namespaces"
    ./kubectl apply -f createNamespaces.yaml
    sleep 5s

    echo "Wait for all calico nodes to be ready"
    check_readiness "calico"

    echo "....Create metallb"
    helm $KEYV metallb bitnami/metallb -n kube-system
    check_readiness "metallb"
    ./kubectl apply -f metallb/metallb-config.yml -n kube-system
    ./kubectl patch configmap config --patch "$(cat metallb/patch-metallb-config.yml)" -n kube-system
    sleep 5s

    echo "....Updating CoreDNS to add RPi nodes"
    ./kubectl apply -f coredns/lab-configmap.yaml  -n kube-system
    ./kubectl apply -f coredns/lab-coredns.yaml -n kube-system
    sleep 5s
    ./kubectl patch configmap coredns --patch "$(cat coredns/patch-coredns-configmap.yml)" -n kube-system
    ./kubectl patch deployment coredns --patch "$(cat coredns/patch-coredns-deployment.yml)" -n kube-system
    sleep 5s

    echo "... NFS client"
    #helm $KEYV nfs-client stable/nfs-client-provisioner -n kube-system --set nfs.server=10.0.0.2 --set nfs.path=/mnt/usb6 --set storageClass.name=nfs-dyn
    cd nfs-subdir-external-provisioner/deploy/helm/
    helm $KEYV nfs-client . -n kube-system --set nfs.server=10.0.0.2 --set nfs.path=/mnt/usb6 --set storageClass.name=nfs-dyn
    cd ../../..
    check_readiness "nfs-client"

    echo " ....Create chronyd"
    ./kubectl apply -f chronyd/chronyd.yaml
    check_readiness "chrony"

    echo "....Create certificates manager"
    for ns in cert-manager kube-system rack01 monitoring kubevirt; do
        if [ $KEYV = 'upgrade' ]; then
            ./kubectl delete configmap private-ca-cert -n ${ns}
            ./kubectl delete secret ca-key-pair -n ${ns}
        fi
        ./kubectl create configmap private-ca-cert --from-file=tls.crt=ca.crt  -n ${ns}
        ./kubectl create secret tls ca-key-pair --cert=ca.crt --key=ca.key -n ${ns}
    done
    # ./kubectl apply -f certmgr/cert-manager.crds.yaml
    sleep 5s
    helm $KEYV cert-manager jetstack/cert-manager -n cert-manager --version v1.1.0 --set installCRDs=true
    check_readiness "cert-manager"
    for ns in cert-manager kube-system rack01 monitoring kubevirt; do
        ./kubectl apply -f certmgr/issuer.yaml -n ${ns}
    done
    sleep 5s

    echo "....Create nginx-ingress"
    helm uninstall nginx-ingress -n nginx-ingress
    # helm $KEYV nginx-ingress -f nginx-ingress/values.yaml stable/nginx-ingress -n nginx-ingress
    helm $KEYV nginx-ingress -f nginx-ingress/values2.yaml ingress-nginx/ingress-nginx -n nginx-ingress
    check_readiness "nginx-ingress"

    echo "....Create Persistent Volumes"
    ./kubectl apply -f persistentVolume/persistentVolume.yaml
    sleep 5s

    echo "....Create keycloack & 389-ds"
    ./kubectl create secret generic realm-secret --from-file=keycloack/realm-export.json -n kube-system
    helm $KEYV keycloak codecentric/keycloak --version 8.2.2 -f keycloack/kcvalues.yml -n kube-system
    check_readiness "keycloak"
    helm $KEYV 389ds gabibbo97/389ds --version 0.1.0
    check_readiness "389ds"

    echo "....Create main apps UI"
    ./kubectl create secret generic gatekeeper-fc --from-file=./forecastle/kc/gatekeeper.yaml -n kube-system
    ./kubectl apply -f forecastle/forecastle2001.yaml -n kube-system
    check_readiness "forecastle"

    echo "....Create K8S dashboard"
    ./kubectl apply -f dashboard/dashboard.yaml -n kubernetes-dashboard
    check_readiness "dashboard"
    ./kubectl create serviceaccount dashboard-admin-sa
    ./kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
    sleep 5s
    ./kubectl apply -f dashboard/ingress.yaml -n kubernetes-dashboard
    sleep 5s

    echo "....Create Registries: helm/docker and tools"
    helm $KEYV harbor harbor/harbor -f registry/harbor/values.yaml -n kube-system
    check_readiness "harbor"
    ./kubectl apply -f registry/dockerRegistry/pvc-claim.yaml -n rack01
    sleep 5s
    helm $KEYV docker-registry stable/docker-registry -f registry/dockerRegistry/registryvalues.yaml -n rack01
    check_readiness "docker-registry"

    echo "....Create netbox"
    ./kubectl create secret generic gatekeeper --from-file=./netbox/kc/gatekeeper.yaml -n kube-system
    ./kubectl apply -f netbox/. -n kube-system
    check_readiness "netbox"

    echo "....Create monitoring"
    ./kubectl apply -f monitoring/kubestatemetrics/. -n kube-system
    ./kubectl apply -f monitoring/grafana/grafanaconfig.yaml -n monitoring
    helm $KEYV prometheus prometheus-community/kube-prometheus-stack -f ./monitoring/kps-values.yaml -n monitoring
    ./kubectl apply -f monitoring/prometheus/clusterrole.yaml -n monitoring
    check_readiness "prometheus"
    
    # DEPRECATED - helm $KEYV prometheus stable/prometheus -f monitoring/prometheus/prometheus.values -n monitoring
    # DEPRECATED - helm $KEYV grafana grafana/grafana -f monitoring/grafana/grafanavalues.yaml -n monitoring
    # DEPRECATED - helm $KEYV karma stable/karma --version 1.5.2 -f monitoring/karma/values.yaml -n monitoring

    echo "....Install JupyterHub"
    export TOKEN=$(openssl rand -hex 32)
    # Token value: 68dfd25df6f95b5f274b2cd85fcfd1dbe777adf866d1729c5b05e9b929ef37ca
    helm $KEYV jupyterhub jupyterhub/jupyterhub --namespace rack01 --values jupyterHub/config.yaml
    check_readiness "jupyterhub"

    echo "....Install Kubevirt"
    export KVIRT_VERSION=$(curl -s https://api.github.com/repos/kubevirt/kubevirt/releases | grep tag_name | grep -v -- '-rc' | head -1 | awk -F': ' '{print $2}' | sed 's/,//' | xargs)
    echo "Kubevirt version: $KVIRT_VERSION"
    ./kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KVIRT_VERSION}/kubevirt-operator.yaml
    ./kubectl create -f https://github.com/kubevirt/kubevirt/releases/download/${KVIRT_VERSION}/kubevirt-cr.yaml
    ./kubectl create configmap kubevirt-config -n kubevirt --from-literal debug.useEmulation=true
    check_readiness "virt"
    ./kubectl create secret tls ca-key-pair --cert=ca.crt --key=ca.key --namespace=rack01

    if [ -d "./singularity_ent" ]; then
        echo "Install Singularity"
        ./kubectl apply -f ./singularity_ent/role.yml
        ./kubectl apply -f ./singularity_ent/singularity-creds.yaml -n kubevirt
        helm $KEYV  singularity -f ./singularity_ent/values.yaml sylabs/singularity-enterprise -n rack01
        helm $KEYV singularity-crds sylabs/singularity-enterprise --values crdDefinitions.frontend.host=cloud.home.lab -n rack01
        check_readiness "singularity"
    fi

    # echo "Install discourse"
    # helm $KEYV discourse bitnami/discourse -f discourse/discourse_values.yaml -n kube-system
    # check_readiness "discourse"

    echo "....Create tftpd"
    ./kubectl apply -f ftpsvc/tftp-hpa/tftp-hpa.yaml -n rack01
    check_readiness "tftp"
    
    echo ".... Create admin container to run ansible playbooks"
    ./kubectl apply -f rpicluster/admin.yaml -n rack01
    ./kubectl apply -f rpicluster/admin.yaml -n kube-system

    echo "Setup backup solution"
    helm $KEYV velero vmware-tanzu/velero -f backup/velero-values.yaml -n kube-system
    check_readiness "velero"

    echo ".... Populate Netbox with default values"
    cd netbox/config && pip3 install -r requirements.txt && python3 netbox_init.py  

    echo "....Create slurmctld"
    ./kubectl apply -f slurmctl/slurm-k8s.yaml -n rack01
    check_readiness "slurm"

    echo "Done"
}

function deploy {
    runcmds "install"
}

function upgrade {
    runcmds "upgrade"
}

function access {
    echo "+++++ Access to services +++++"
    echo "K8S dashboard: https://kubernetes.home.lab"
    echo "    Token: "
    ./kubectl describe secret $(./kubectl get secrets | grep dashboard-admin-sa-token | awk '{ print $1 }' ) | grep "token:" | awk '{ print $2 }'
    echo ""
    echo "Monitoring dashboard: https://grafana.home.lab"
    echo "    Login: admin"
    echo "    Password: (in secrets)"
    gp=$(./kubectl get secret --namespace monitoring grafana -o jsonpath="{.data.admin-password}")
    echo $gp | base64 -d
    echo ""
    echo ""
    echo "Docker registry UI: https://registryui.home.lab"
    echo "++++++++++++++++++++++++++++++"
}

while [[ $# -gt 0 ]]
do
    key="${1}"
    case ${key} in
    -a|--access)
        access
        exit 0
        ;;
    -c|--create)
        echo "Create environment"
        create
        exit 0
        ;;
    -d|--deploy)
        echo "Deploy environment"
        deploy
        exit 0
        ;;
    -r|--remove)
        echo "Remove environment"
        remove
        exit 0
        ;;
    -i|--reset)
        echo "Reset environment"
        reset
        exit 0
        ;;
    -u|--upgrade)
        echo "Upgrading environment"
        upgrade
        exit 0
        ;;
    *)  # unknown option
        echo "Arguments missing"
        echo "./pb-install-all.sh [-a|-c|-d|-r|-i]"
        echo "  -a: Print access endpoints"
        echo "  -d: Deploy all services on existing cluster"
        echo "  -r: Delete the whole cluster and all services"
        echo "  -i: Delete all services running on the cluster"
        echo "  -u: Upgrade all services running on the cluster"
        exit 0
        ;;
    esac
done