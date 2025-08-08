#!/usr/bin/bash

echo "🚀 Starting environment setup..."

# Install additional tools
echo "📦 Installing kubectx, kubens, k9s, and fzf..."
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
brew install derailed/k9s/k9s
sudo apt-get install fzf -y

# Install Argo CD CLI
echo "📦 Installing Argo CD CLI..."
curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

# Set up kubectl aliases
echo "🔧 Setting up kubectl aliases..."
cat << 'EOF' >> /home/$USER/.bashrc
alias k="kubectl"
alias kga="kubectl get all"
alias kgn="kubectl get all --all-namespaces"
alias kdel="kubectl delete"
alias kd="kubectl describe"
alias kg="kubectl get"
EOF

echo "✅ Environment setup complete!"
echo "✅ The following aliases were added:"
echo "  - k = kubectl"
echo "  - kga = kubectl get all"
echo "  - kgn = kubectl get all --all-namespaces"
echo "  - kdel = kubectl delete"
echo "  - kd = kubectl describe"
echo "  - kg = kubectl get"

source ~/.bashrc