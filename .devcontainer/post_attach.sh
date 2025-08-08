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

# Deploy Flask application via kubectl (no CLI needed)
echo "🍶 Deploying Flask application..."

# Get repository URL
if [ -d ".git" ]; then
    REPO_URL=$(git config --get remote.origin.url)
    if [[ $REPO_URL == git@github.com:* ]]; then
        # Convert SSH to HTTPS
        REPO_URL=$(echo $REPO_URL | sed 's/git@github.com:/https:\/\/github.com\//')
    fi
    if [[ $REPO_URL != *.git ]]; then
        REPO_URL="${REPO_URL}.git"
    fi
    echo "📍 Repository URL: $REPO_URL"
else
    echo "❌ Not in a git repository - Flask app creation will fail"
    exit 1
fi

# Check if flask-helm directory exists
if [ ! -d "flask-helm" ]; then
    echo "❌ flask-helm directory not found - make sure it exists in your repository"
    exit 1
fi

# Create Flask application using template
echo "📱 Creating Flask application in Argo CD..."

if [ -f "flask-demo-app.template.yaml" ]; then
    # Use template file approach
    echo "📝 Using template file approach..."
    sed "s|REPLACE_REPO_URL|$REPO_URL|g" flask-demo-app.template.yaml | kubectl apply -f -
else
    # Fallback to inline YAML
    echo "📝 Using inline YAML approach..."
    cat << EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: flask-demo
  namespace: argocd
spec:
  project: default
  source:
    repoURL: $REPO_URL
    targetRevision: HEAD
    path: flask-helm
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
    - CreateNamespace=true
EOF
fi

if [ $? -eq 0 ]; then
    echo "✅ Flask application created successfully!"
    echo "⏳ Argo CD will automatically sync the application..."
else
    echo "❌ Failed to create Flask application"
    echo "    Repository: $REPO_URL"
    echo "    Path: flask-helm"
fi

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
echo "   kubectl get pods -n argocd           # Check pod status"
echo "   kubectl get applications -n argocd   # Check Argo CD applications"
echo "   kubectl get app flask-demo -n argocd # Check Flask app status"
echo ""