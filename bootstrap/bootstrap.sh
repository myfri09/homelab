#!/bin/bash

echo "Starting Homelab Bootstrap..."

# Check basicmake get-password
s
which kubectl || { echo "kubectl not found"; exit 1; }
which helm || { echo "helm not found"; exit 1; }

echo "Installing ArgoCD..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl create namespace argocd 2>/dev/null || true

helm upgrade --install argocd argo/argo-cd \
    --namespace argocd \
    --version 7.7.6 \
    --set global.domain=argocd.myfri09.lan \
    --set server.service.type=ClusterIP \
    --set server.extraArgs={--insecure} \
    --set configs.params."server\.insecure"=true \
    --wait --timeout 10m

echo "Waiting for ArgoCD pods..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

echo "ArgoCD Password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "Deploying root application..."
kubectl apply -f clusters/staging/argocd/root-app.yaml

echo "Bootstrap complete!"
