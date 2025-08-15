# GitOps & Container Registry workshop

This repository contains a preconfigured environment through GitHub Codespaces.  

## GitOps

GitOps treats a Git repository as the single source of truth for infrastructure and applications. When you commit your desired state to Git, an automated tool ensures your running application matches the repository code. This approach brings all the benefits of Git to deployments.

## Container Registry

A container registry is a central location that hosts container images. There are a number of free public container registries, ghcr.io, quay.io, and hub.docker.com for example. The CIRRUS platform run by CISL contains its own container registry, https://hub.k8s.ucar.edu/, available to all UCAR staff. In order to push images to the CISL Container Registry, built on [Harbor](https://goharbor.com/), a CIRRUS admin has to create a project and add you to it. 

At this point in the workshop we will add everyone to the gitops-workshop project with admin privileges. 

**Note:** If you prefer to use a public repository like Docker Hub you can do this and still follow along with the workshop content. 

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

## Argo CD

Argo CD is a continuous delivery tool that specializes in GitOps. An Argo CD application is defined by the git URL, Helm chart directory location, and git branch that contains the Helm chart. Argo CD monitors the directory every 3 minutes and can be configured to automatically deploy any changes.

**Workshop Flow:**
This workshop is preconfigured with an Argo CD Application using the `flask-helm` directory in your fork. Currently it uses an existing container image. We'll add a GitHub Actions workflow to:
1. Build a new container when changes are made to `flask-app/`
2. Push the new image to the container registry
3. Update the application's `values.yaml` file with new image details
4. Push changes back to the repository automatically

## Helm Chart

This repository contains a pre-built Flask application with a Dockerfile to create a container image and a Helm chart directory, `flask-helm/`. The Helm chart follows standard conventions:

* `templates/` directory with Kubernetes object definitions
* `values.yaml` file to provide configurable values for the templates
* `Chart.yaml` file that provides metadata about the Helm chart

### Templates

Kubernetes deploys different object types. These objects are defined in YAML files within the `templates/` directory. For this simple web application, we only need two objects:

* `templates/deployment.yaml` - Defines the containers to run, replicas, and resource requirements
* `templates/service.yaml` - Exposes the deployment containers on the Kubernetes network

The templates use Helm's templating syntax (e.g., `{{ .Values.webapp.container.image }}`) to substitute values from `values.yaml`, making the chart reusable across different environments.

### Values

The `values.yaml` file contains default configuration values that can be overridden during deployment. This includes settings like:
- Container image name and tag
- Service port configuration
- Resource limits and requests
- Replica count

## Access Container Application

Let's forward the container application and look at it live. In the terminal run

```
kubectl port-forward svc/flask-demo -n argocd 8001:5000
```

The application is now available at http://127.0.0.1:8001. There will be a pop up in the bottom right corner with an `Open in Browser` button for quick access. 

<img src="https://github.com/NicholasCote/gitops-harbor-workshop/blob/main/media/gitops-forward.png" alt="Fork" style="margin: auto">

