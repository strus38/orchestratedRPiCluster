##
## Since running from Windows 10... ansible is not available and we have a chicken/egg issue :-)
##

function check_readiness {
    ready=false
    while  [ "$ready" = false ]; do
        ready=true
        for i in $(./kubectl get pods --all-namespaces |  grep  $1 | awk '{ print $3 }'); do
            if [ $i != "1/1" ]; then
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
    helm delete $(helm list --short)
}

function deploy {
    echo "-----"
    echo "Checking Environment"
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
    echo "Testing binaries"
    ./kubectl version
    helm version
    ./kubectl config view --raw >/tmp/config
    export KUBECONFIG=/tmp/config
    echo "Updating Helm repos"
    helm repo update
    echo "Environment READY"
    echo "-----"

    echo "Starting configuration of all services..."
    ./kubectl get nodes
    echo "....Create namespaces"
    ./kubectl apply -f createNamespaces.yaml
    sleep 5s

    echo "Wait for all calico nodes to be ready"
    check_readiness "calico"

    echo "....Create metallb"
    helm install metallb stable/metallb -n kube-system
    check_readiness "metallb"
    ./kubectl apply -f metallb/metallb-config.yml
    sleep 5s

    echo "....Create coredns"
    ./kubectl apply -f coredns/.
    check_readiness "coredns"

    echo " ....Create chronyd"
    ./kubectl apply -f chronyd/chronyd.yaml
    check_readiness "chrony"

    echo "....Create certificates manager"
    ./kubectl apply -f certmgr/cert-manager.crds.yaml
    sleep 5s
    helm install cert-manager jetstack/cert-manager -n cert-manager --version v0.15.0
    check_readiness "cert-manager"
    ./kubectl apply -f certmgr/issuer.yaml
    sleep 5s

    echo "....Create nginx-ingress"
    helm install nginx-ingress -f nginx-ingress/values.yaml stable/nginx-ingress -n nginx-ingress
    check_readiness "nginx-ingress"

    echo "....Create Persistent Volumes"
    ./kubectl apply -f persistentVolume/persistentVolume.yaml
    sleep 5s

    echo "....Create K8S dashboard"
    ./kubectl apply -f dashboard/dashboard.yaml
    check_readiness "dashboard"
    ./kubectl create serviceaccount dashboard-admin-sa
    ./kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa
    sleep 5s
    ./kubectl apply -f dashboard/ingress.yaml
    sleep 5s

    echo "....Create DockerRegistry"
    helm install registry stable/docker-registry -n rack01 -f registry/dockerRegistry/registryvalues.yaml
    check_readiness "registry"
    echo "....Create Docker Registry UI"
    ./kubectl apply -f registry/dockerRegistry/registryui.yaml
    check_readiness "registryui"

    echo "....Create monitoring"
    helm install prometheus stable/prometheus -f monitoring/prometheus/prometheus.values -n monitoring
    check_readiness "prometheus"
    ./kubectl apply -f monitoring/kubestatemetrics/.
    ./kubectl apply -f monitoring/grafana/grafanaconfig.yaml
    helm install grafana stable/grafana -f monitoring/grafana/grafanavalues.yaml -n monitoring
    check_readiness "grafana"

    echo "....Create tftpd"
    ./kubectl apply -f ftpsvc/tftp-hpa/tftp-hpa.yaml
    check_readiness "tftp"
    ./kubectl apply -f ftpsvc/tftp-hpa/ingress.yaml

    echo "....Create slurmctld"
    ./kubectl apply -f slurmctld/slurm-k8s.yaml
    check_readiness "slurm"

    echo "Done"
}

while [[ $# -gt 0 ]]
do
    key="${1}"
    case ${key} in
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
        echo "Missing at least 1 argument: -c or -d or -r"
        exit 1
        ;;
    esac
done