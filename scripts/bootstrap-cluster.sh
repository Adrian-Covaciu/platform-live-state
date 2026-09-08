#!/bin/bash
set -euo pipefail

CLUSTER_NAME=context-homelab-czde334ksta

# Create Kind cluster (guarded — kind create cluster fails if it already exists)
if ! kubectl config current-context | grep -qx "$CLUSTER_NAME"; then
  echo "Exiting because wrong context is selected"
  exit 1
fi

# Add Traefik Helm repository
helm repo add traefik https://helm.traefik.io/traefik
helm repo update

# Install Gateway API CRDs from the Standard channel.
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.6.1/standard-install.yaml

# Install Traefik configured for kind port-mapping (helm upgrade --install is already idempotent)
helm upgrade --install traefik traefik/traefik \
  --namespace traefik-ingress \
  --create-namespace \
  --set providers.kubernetesGateway.enabled=true \
  --set service.type=LoadBalancer \
  --set "service.annotations.oci\.oraclecloud\.com/load-balancer-type=nlb"

# Install cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true

# Install ArgoCD (namespace guarded, apply is idempotent)
if ! kubectl get namespace argocd >/dev/null 2>&1; then
  kubectl create namespace argocd
fi
kubectl apply -n argocd --server-side --force-conflicts -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "Waiting for ArgoCD pods to be ready..."
kubectl wait --for=condition=Ready pod --all -n argocd --timeout=300s

echo
echo "ArgoCD is ready. Username: admin"
echo "Get the initial admin password with:"
echo "kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

