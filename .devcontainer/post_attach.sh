#!/usr/bin/bash

echo "🎯 Starting Kubernetes cluster and Argo CD setup..."

# Start minikube
echo "🚀 Starting minikube..."
minikube start

# Wait for minikube to be ready
echo "⏳ Waiting for minikube to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s

# Install Argo CD
echo "📦 Installing Argo CD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply insecure configuration if the file exists
if [ -f "argocd-insecure-install.yaml" ]; then
    kubectl apply -f argocd-insecure-install.yaml
fi

# Restart Argo CD server
kubectl rollout restart deployment argocd-server -n argocd

# Wait for Argo CD pods to be ready
echo "⏳ Waiting for Argo CD to be ready (this may take a few minutes)..."
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s

# Deploy Flask application via Argo CD CLI
echo "🍶 Deploying Flask application..."
sleep 10  # Give Argo CD server a moment to fully start

# Get the initial admin secret for CLI login
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Create the application using Argo CD CLI
argocd app create flask-demo \
  --repo https://github.com/$(cat .git/config | grep "url = " | cut -d'/' -f4-5 | cut -d'.' -f1).git \
  --path flask-helm \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace argocd \
  --sync-policy automated \
  --auto-prune \
  --self-heal \
  --server localhost:8002 \
  --username admin \
  --password "$ARGOCD_PASSWORD" \
  --insecure || echo "⚠️  Argo CD CLI app creation failed - you can create it manually via the UI"

# Wait for application to be synced
echo "⏳ Waiting for Flask application to be deployed..."
sleep 30

echo ""
echo "🎉 Setup complete!"
echo ""
echo "📋 Quick Access Information:"
echo "================================"
echo "🌐 Argo CD UI: https://127.0.0.1:8002"
echo "   Username: admin"
echo "   Password: $ARGOCD_PASSWORD"
echo ""
echo "🍶 Flask App: http://127.0.0.1:8001 (after port-forward)"
echo ""
echo "🚀 To access the services, run these port-forward commands:"
echo "   Terminal 1: kubectl port-forward svc/argocd-server -n argocd 8002:80"
echo "   Terminal 2: kubectl port-forward svc/flask-demo -n argocd 8001:5000"
echo ""
echo "📖 Useful commands:"
echo "   kubectl get pods -n argocd      # Check pod status"
echo "   kubectl get apps -n argocd      # Check Argo CD applications"
echo "   argocd app list                 # List apps via CLI"
echo ""