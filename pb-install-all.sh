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
    helm delete nfs-client -n kube-system
    helm delete cert-manager -n cert-manager || exit
    helm delete nginx-ingress -n nginx-ingress || exit
    helm delete docker-registry -n rack01 || exit
    helm delete chartmuseum -n rack01 || exit
    helm delete prometheus -n monitoring || exit
    helm delete grafana -n monitoring || exit
    helm delete karma -n monitoring || exit
    ./kubectl delete -f keycloack/. -n kube-system --force || exit
    ./kubectl delete -f netbox/. -n kube-system --force || exit
    ./kubectl delete -f monitoring/kubestatemetrics/. -n kube-system --force || exit
    ./kubectl delete ns kubernetes-dashboard --force || exit
    ./kubectl delete ns rack01 --force || exit
    ./kubectl delete ns cert-manager --force || exit
    ./kubectl delete ns monitoring --force || exit
    ./kubectl delete ns nginx-ingress --force || exit
}

function deploy {
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
            helm repo add  stable https://kubernetes-charts.storage.googleapis.com/
            helm repo add  pnnl-miscscripts https://pnnl-miscscripts.github.io/charts
            helm repo add  pojntfx https://pojntfx.github.io/charts/
            helm repo add  bitnami https://charts.bitnami.com/bitnami
            helm repo add  akomljen-charts https://raw.githubusercontent.com/komljen/helm-charts/master/charts/
            helm repo add  elastic https://helm.elastic.co
            helm repo add  jetstack https://charts.jetstack.io
        fi
    fi
    echo "### Testing binaries"
    ./kubectl version || exit
    helm version || exit
    ./kubectl config view --raw >/tmp/config
    export KUBECONFIG=/tmp/config
    echo "###  Updating Helm repos"
    helm repo update || exit
    echo "Environment READY"
    echo "-----"

    if [ ! -f "/usr/local/bin/checkov" ]; then 
        echo "### Issuing security report"
        checkov -d . --framework kubernetes -o junitxml 2> checkov.results.xml || exit
        junit2html checkov.results.xml > checkov.html || exit
    fi

    echo "### Starting configuration of all services..."
    ./kubectl get nodes || exit
    echo "....Create namespaces"
    ./kubectl apply -f createNamespaces.yaml || exit
    sleep 5s

    echo "Wait for all calico nodes to be ready"
    check_readiness "calico"

    echo "....Create metallb"
    helm install metallb stable/metallb -n kube-system || exit
    check_readiness "metallb"
    ./kubectl apply -f metallb/metallb-config.yml || exit
    sleep 5s

    echo "....Update coredns, please do it manually"
    ./kubectl apply -f coredns/lab-configmap.yaml || exit
    echo "Waiting custom coredns configuration to be applied"
    while [ true ] ; do
        read -t 3 -n 1
        if [ $? = 0 ] ; then
            break
        else
        echo "Please customize CoreDNS based on coredns/README.md file and press the space key..."
        fi
    done

    echo "... NFS client"
    helm install nfs-client stable/nfs-client-provisioner -n kube-system --set nfs.server=10.0.0.2 --set nfs.path=/mnt/usb --set storageClass.name=nfs-dyn
    check_readiness "nfs-client"

    #echo " ....Create chronyd"
    #./kubectl apply -f chronyd/chronyd.yaml
    #check_readiness "chrony"

    echo "....Create certificates manager"
    ./kubectl apply -f certmgr/cert-manager.crds.yaml || exit
    sleep 5s
    helm install cert-manager jetstack/cert-manager -n cert-manager --version v0.15.0 || exit
    check_readiness "cert-manager"
    ./kubectl apply -f certmgr/issuer.yaml -n cert-manager || exit
    ./kubectl apply -f certmgr/issuer.yaml -n rack01 || exit
    sleep 5s

    echo "....Create nginx-ingress"
    helm install nginx-ingress -f nginx-ingress/values.yaml stable/nginx-ingress -n nginx-ingress || exit
    check_readiness "nginx-ingress"

    echo "....Create Persistent Volumes"
    ./kubectl apply -f persistentVolume/persistentVolume.yaml || exit
    sleep 5s

    echo "....Create keycloack"
    ./kubectl apply -f keycloack/. -n kube-system || exit
    check_readiness "keycloack"

    echo "....Create K8S dashboard"
    ./kubectl apply -f dashboard/dashboard.yaml -n kubernetes-dashboard || exit
    check_readiness "dashboard"
    ./kubectl create serviceaccount dashboard-admin-sa || exit
    ./kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa || exit
    sleep 5s
    ./kubectl apply -f dashboard/ingress.yaml -n monitoring || exit
    sleep 5s

    echo "....Create DockerRegistry"
    ./kubectl apply -f registry/dockerRegistry/pvc-claim.yaml -n rack01 || exit
    sleep 5s
    helm install docker-registry stable/docker-registry -f registry/dockerRegistry/registryvalues.yaml -n rack01 || exit
    check_readiness "docker-registry"

    echo "....Create Docker Registry UI"
    ./kubectl apply -f registry/dockerRegistry/docker-ui.yaml -n rack01 || exit
    check_readiness "registryui"
    
    echo "....Create ChartMuseum"
    ./kubectl apply -f registry/chartMuseum/pvc-claim.yaml -n rack01 || exit
    sleep 5s
    helm install chartmuseum -f ./registry/chartMuseum/cmvalues.yaml stable/chartmuseum -n rack01 || exit
    check_readiness "chartmuseum"

    echo "....Create netbox"
    ./kubectl apply -f netbox/. -n kube-system || exit
    check_readiness "netbox"

    echo "....Create monitoring"
    helm install prometheus stable/prometheus -f monitoring/prometheus/prometheus.values -n monitoring || exit
    ./kubectl apply -f monitoring/prometheus/clusterrole.yaml -n monitoring || exit
    check_readiness "prometheus"
    ./kubectl apply -f monitoring/kubestatemetrics/. -n kube-system || exit
    ./kubectl apply -f monitoring/grafana/grafanaconfig.yaml -n monitoring || exit
    helm install grafana stable/grafana -f monitoring/grafana/grafanavalues.yaml -n monitoring || exit
    check_readiness "grafana"
    helm install karma stable/karma --version 1.5.2 -f monitoring/karma/values.yaml -n monitoring || exit
    check_readiness "karma"

    echo "....Create tftpd"
    ./kubectl apply -f ftpsvc/tftp-hpa/tftp-hpa.yaml -n rack01 || exit
    check_readiness "tftp"
    ./kubectl apply -f ftpsvc/tftp-hpa/ingress.yaml -n rack01 || exit

    echo "....Create slurmctld"
    ./kubectl apply -f slurmctl/slurm-k8s.yaml -n rack01 || exit
    check_readiness "slurm"

    echo "... Create Clair-Klar"
    ./kubectl create secret generic clairsecret --from-file=clair-cve/config.yaml -n rack01 || exit                                        
    ./kubectl apply -f ./clair-cve/clair-cve.yaml -n rack01 || exit
    check_readiness "clair"

    echo ".... Populate Netbox with default values"
    cd netbox/config && pip3 install -r requirements.txt && python3 netbox_init.py || exit

    echo "Done"
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
    *)  # unknown option
        echo "Arguments missing"
        echo "./pb-install-all.sh [-a|-c|-d|-r|-i]"
        echo "  -a: Print access endpoints"
        echo "  -d: Deploy all services on existing cluster"
        echo "  -r: Delete the whole cluster and all services"
        echo "  -i: Delete all services running on the cluster"
        exit 0
        ;;
    esac
done