# GitOps & Container Registry workshop

This repository contains a preconfigured environment through GitHub Codespaces.  

## Getting Started

1. **Fork** this repository into your own GitHub account. 
    <img src="https://github.com/NicholasCote/gitops-harbor-workshop/blob/main/media/gitops-fork.png" alt="Fork" style="margin: auto"><br>
    a. **Owner** will be your GitHub username 
2. Select the button labeled `<> Code` in the upper right
3. Select the Codespaces tab 
4. Use the `Create codespace on main` button to launch a new codespace
    <img src="https://github.com/NicholasCote/gitops-harbor-workshop/blob/main/media/gitops-codespace.png" alt="Fork" style="margin: auto">

## Codespace & devcontainer

When the codespace starts, it looks to `.devcontainer/devcontainer.json` for configuration including ports to forward, scripts to run automatically, customizations, and host resource requirements. 

**Container Creation (runs once):**
- `.devcontainer/startup_script.sh` installs Kubernetes management tools (kubectx, kubens, k9s, ArgoCD CLI) and configures kubectl aliases

**Post-Attach (runs each time you connect):**
- `.devcontainer/post_attach.sh` sets up the workshop environment:
  - Installs minikube
  - Waits for minikube to be ready 
  - Installs Argo CD
  - Updates Argo CD for HTTP access
  - Restarts Argo CD to apply changes
  - Deploys a Flask application to Argo CD
  - Provides access information

It takes a minute for these to complete. You will see output in the terminal at the bottom of the screen and this on successful completion.
    <img src="https://github.com/NicholasCote/gitops-harbor-workshop/blob/main/media/gitops-setup.png" alt="Fork" style="margin: auto">