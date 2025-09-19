#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Create Kind Cluster ---
echo "🚀 Creating Kind cluster..."
kind create cluster --config 01-cluster-setup/kind-config.yaml

# --- Install Metrics Server ---
echo "📈 Installing Metrics Server..."
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
echo "⏳ Waiting for Metrics Server to be ready..."
kubectl wait --namespace kube-system \
  --for=condition=ready pod \
  --selector=k8s-app=metrics-server \
  --timeout=120s

# --- Install Ingress Controller ---
echo "🔌 Installing Ingress NGINX controller..."
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
echo "⏳ Waiting for Ingress controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# --- Install Headlamp (Kubernetes Dashboard) ---
echo "💡 Installing Headlamp dashboard..."
# Apply RBAC first
kubectl apply -f 01-cluster-setup/headlamp-rbac.yaml
# Add Helm repo and install Headlamp
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm install headlamp headlamp/headlamp --namespace kube-system
# Apply Headlamp Ingress
kubectl apply -f 01-cluster-setup/headlamp-ingress.yaml

echo "✅ Setup complete!"
echo "🎉 Your Kubernetes learning environment is ready."
echo "👉 Access the Headlamp dashboard at: http://headlamp.localtest.me"
echo "🔑 Your Headlamp login token is:"
kubectl create token headlamp-admin -n kube-system
