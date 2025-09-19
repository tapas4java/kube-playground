#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Create Kind Cluster ---
echo "🚀 Creating Kind cluster..."
kind create cluster --config 00-cluster-setup/kind-config.yaml

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
kubectl apply -f 00-cluster-setup/headlamp-rbac.yaml
# Add Helm repo and install Headlamp
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm repo update
helm install headlamp headlamp/headlamp --version 0.35.0 --namespace kube-system
# Apply Headlamp Ingress
kubectl apply -f 00-cluster-setup/headlamp-ingress.yaml

# --- Install Monitoring Stack ---
echo "📈 Installing Full Observability Stack (Prometheus, Grafana, Loki, Tempo)..."
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
# Install Prometheus & Grafana
helm install prometheus prometheus-community/kube-prometheus-stack --version 77.9.1 --namespace monitoring --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
# Install Loki
helm install loki grafana/loki-stack --version 2.10.2 --namespace monitoring
# Install Tempo
helm install tempo grafana/tempo --version 1.8.0 --namespace monitoring
# Apply ServiceMonitors for the shopping cart app
kubectl apply -f 20-shopping-cart-app/servicemonitors.yaml
# Apply Grafana Ingress
kubectl apply -f 00-cluster-setup/grafana-ingress.yaml

echo "✅ Setup complete!"
echo "🎉 Your Kubernetes learning environment is ready."
echo "👉 Access the Headlamp dashboard at: http://headlamp.localtest.me"
echo "🔑 Your Headlamp login token is:"
kubectl create token headlamp-admin -n kube-system
echo "👉 Access the Grafana dashboard at: http://grafana.localtest.me (admin/prom-operator)"
