#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
REPO_URL="https://github.com/myfri09/homelab"
CLUSTER_NAME="homelab"
ARGOCD_NAMESPACE="argocd"
ARGOCD_VERSION="7.7.6"

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

check_prerequisites() {
    log "Checking prerequisites..."

    if ! command -v kubectl &> /dev/null; then
        error "kubectl not found. Please install kubectl."
        exit 1
    fi

    if ! command -v helm &> /dev/null; then
        error "helm not found. Please install helm."
        exit 1
    fi

    if ! kubectl cluster-info &> /dev/null; then
        error "Cannot connect to Kubernetes cluster. Please check your kubeconfig."
        exit 1
    fi

    # Fixed: Simpler node readiness check
    NOT_READY=$(kubectl get nodes --no-headers | grep -v " Ready " | wc -l)

    if [ "$NOT_READY" -gt 0 ]; then
        error "Not all nodes are ready. $NOT_READY nodes are not ready."
        kubectl get nodes
        exit 1
    fi

    log "✓ All prerequisites met"
}

install_argocd() {
    log "Installing ArgoCD..."

    helm repo add argo https://argoproj.github.io/argo-helm
    helm repo update

    kubectl create namespace $ARGOCD_NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

    cat <<EOF | helm upgrade --install argocd argo/argo-cd \
        --namespace $ARGOCD_NAMESPACE \
        --version $ARGOCD_VERSION \
        --wait \
        --timeout 10m \
        -f -
global:
  domain: argocd.myfri09.lan

configs:
  params:
    server.insecure: true
    server.disable.auth: false

server:
  service:
    type: ClusterIP
  extraArgs:
    - --insecure

  config:
    repositories: |
      - url: ${REPO_URL}
        type: git
        name: homelab

repoServer:
  resources:
    limits:
      memory: 512Mi
    requests:
      memory: 256Mi

controller:
  resources:
    limits:
      memory: 1Gi
    requests:
      memory: 512Mi
EOF

    log "✓ ArgoCD installed"
}

wait_for_argocd() {
    log "Waiting for ArgoCD to be ready..."

    kubectl wait --for=condition=ready pod \
        -l app.kubernetes.io/name=argocd-server \
        -n $ARGOCD_NAMESPACE \
        --timeout=300s

    log "✓ ArgoCD is ready"
}

get_argocd_password() {
    log "Getting ArgoCD admin password..."

    ARGOCD_PASSWORD=$(kubectl -n $ARGOCD_NAMESPACE get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d)

    if [ -z "$ARGOCD_PASSWORD" ]; then
        warning "Could not retrieve initial admin password"
    else
        log "ArgoCD admin password: ${GREEN}$ARGOCD_PASSWORD${NC}"
        log "Save this password securely!"
    fi
}

deploy_root_app() {
    log "Deploying root application..."

    kubectl apply -f clusters/staging/argocd/root-app.yaml

    log "✓ Root application deployed"
}

main() {
    log "Starting Homelab Bootstrap Process"
    log "====================================="

    check_prerequisites
    install_argocd
    wait_for_argocd
    get_argocd_password
    deploy_root_app

    log "====================================="
    log "✓ Bootstrap completed successfully!"
    log ""
    log "Access points:"
    log "  ArgoCD: http://argocd.myfri09.lan"
    log "  Dashboard: http://dashboard.myfri09.lan"
    log "  Vault: http://vault.myfri09.lan"
    log "  Homarr: http://homarr.myfri09.lan"
    log "  Linkding: http://linkding.myfri09.lan"
    log ""
    log "Next steps:"
    log "1. Access ArgoCD UI and verify all applications are synced"
    log "2. Initialize Vault and configure secrets"
    log "3. Update DNS records for *.myfri09.lan to point to MetalLB IP"
}

main "$@"
