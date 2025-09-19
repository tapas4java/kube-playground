# Mastering Kubernetes Concepts with Hands-On Examples

> 💡 **Easiest Way to Start:** This repository is configured with [Devbox](#-quick-start-with-devbox) to instantly create a complete Kubernetes learning environment with `kind`, `kubectl`, `helm`, and all other tools pre-installed. Just run `devbox shell` to begin!

This repository contains all the manifests, scripts, and examples from the blog post series "Mastering Kubernetes Concepts with Hands-On Examples".

This post aims to demystify key Kubernetes concepts through practical examples. We'll use kubectl commands to interact with our local Kind Kubernetes cluster. Kubernetes, a powerful platform for orchestrating containerized applications, can be overwhelming for newcomers. In Part 1, we learned what Kubernetes is, why it matters, and explored basic concepts.

In this Part 2, we'll go through every basics to advanced Kubernetes concept one by one, with hands-on examples you can try in your own local Kind cluster. Think of this as your Kubernetes survival kit.

## 🚀 Prerequisites

The only prerequisite for this tutorial is to have Devbox installed. You can install it by running the following command in your terminal:

```bash
curl -fsSL https://get.jetpack.io/devbox | bash
```

Once Devbox is installed, it will provide a complete, isolated environment with all the other tools you need.

## 🚀 Quick Start with Devbox

With Devbox installed, you can get the entire learning environment up and running with a single command.

1.  Clone this repository.
2.  Run the following command in the root of the repository:

    ```bash
    devbox shell
    ```

This will drop you into a shell with `kind`, `kubectl`, `helm`, `k9s`, and `kustomize` installed and ready to go. You can now proceed to the cluster setup.

## 🚀 Cluster Setup

Now that you are inside the Devbox shell, you can create your local Kubernetes cluster and install the dashboard.

**1. Create the Kind Cluster**

A Kind configuration file is provided in `01-cluster-setup/kind-config.yaml`. This configuration sets up a multi-node cluster running Kubernetes v1.29.2 and maps the necessary ports (80 for HTTP and 443 for HTTPS) from your local machine to the cluster's Ingress controller.

To create the cluster, run the following command:
```bash
kind create cluster --config 01-cluster-setup/kind-config.yaml
```

**2. Install Kubernetes Dashboard (Headlamp)**

For a visual way to explore your cluster, we'll install Headlamp. For this, and for our monitoring setup later, we will use **Helm**.

**What is Helm?**
[Helm](https://helm.sh/) is the package manager for Kubernetes. It helps you define, install, and upgrade even the most complex Kubernetes applications using "Charts". Think of it like `apt` or `brew` for Kubernetes. It simplifies the process of deploying and managing applications.

Now, let's use Helm to install Headlamp.

First, create a service account with cluster-admin privileges for Headlamp to use. This is suitable for a local learning environment.
```bash
kubectl apply -f 01-cluster-setup/headlamp-rbac.yaml
```

Next, add the Headlamp Helm repository and install it:
```bash
helm repo add headlamp https://kubernetes-sigs.github.io/headlamp/
helm install headlamp headlamp/headlamp --namespace kube-system
```

**3. Install an Ingress Controller**

To use `Ingress` resources, you need an Ingress controller. We'll install `ingress-nginx`, which is designed to work with Kind.
```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
You can wait for the controller to be ready by running:
```bash
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=90s
```

**4. Access Headlamp via Ingress**

To access the dashboard, we will use an `Ingress` resource, which exposes services to the outside world.

> **Note:** Don't worry too much about the details of Ingress for now. We will cover it in depth in a later section. This is just to get the dashboard running.

First, apply the Ingress manifest:
```bash
kubectl apply -f 01-cluster-setup/headlamp-ingress.yaml
```

Now, you can open your browser and navigate to `http://headlamp.localtest.me`. This special domain automatically resolves to your local machine, so you don't need to edit your `/etc/hosts` file.

To log in, you will need a token from the `headlamp-admin` service account. Generate one with this command:
```bash
kubectl create token headlamp-admin -n kube-system
```
Copy the token and paste it into the Headlamp login screen. You now have full access to your cluster through a web UI.

## Repository Structure

The repository is organized by Kubernetes concepts, with each directory containing the relevant manifests and instructions.

- `/01-cluster-setup`: Configuration for the Kind cluster and Headlamp dashboard.
- `/02-namespaces`: `dev` and `prod` namespace examples.
- `/03-pods`: Basic Pod examples.
- `/04-replicasets`: ReplicaSet examples.
- `/05-deployments`: Deployment examples.
- `/06-services`: Service examples (ClusterIP, NodePort).
- `/07-configmaps-secrets`: ConfigMap and Secret examples.
- `/08-volumes`: PersistentVolume and PersistentVolumeClaim examples.
- `/09-statefulsets`: StatefulSet examples.
- `/10-daemonsets`: DaemonSet examples.
- `/11-jobs-cronjobs`: Job and CronJob examples.
- `/12-probes`: Liveness, Readiness, and Startup Probe examples.
- `/13-autoscaling`: Horizontal Pod Autoscaler instructions.
- `/14-scheduling`: Node affinity and taints/tolerations examples.
- `/15-network-policies`: Network Policy examples.
- `/16-rbac`: RBAC, Service Account, and ResourceQuota examples.
- `/17-ingress`: Ingress and NGINX Ingress Controller examples.
- `/18-custom-resources`: Custom Resource Definition (CRD) examples.
- `/19-shopping-cart-app`: A complete shopping cart application with frontend, backend, and database.
- `/20-productionize-shopping-cart`: A section for productionizing the app with monitoring.

### 🛍️ Example Application: Shopping Cart

The `/19-shopping-cart-app` directory contains a fully functional, multi-tier application to demonstrate how various Kubernetes resources work together.

**Application Architecture:**

*   **Frontend:** A React application that provides the user interface. It communicates with the backend API. It is exposed via a `NodePort` service.
*   **Backend:** A Node.js application that provides the API for the frontend. It connects to the PostgreSQL database to store and retrieve data.
*   **Database:** A PostgreSQL database for persistent storage. It uses a `PersistentVolumeClaim` to ensure data is not lost when the pod is restarted. It also uses a `Secret` to manage database credentials securely.

**How to Deploy:**

1.  Make sure you are in the root of the repository.
2.  Apply all the manifests in the `19-shopping-cart-app` directory. This will deploy the frontend, backend, database, and the Ingress to expose the application.
    ```bash
    kubectl apply -f 19-shopping-cart-app/
    ```
3.  Verify that all the pods are running:
    ```bash
    kubectl get pods
    ```
    You should see pods for the frontend, backend, and database.

**How to Access:**

You can now access the shopping cart application at `http://cart.localtest.me`.

### 🏭 Productionizing the App with Monitoring

The final step is to install a complete monitoring stack using the `kube-prometheus-stack` Helm chart. This stack includes Prometheus for collecting metrics and Grafana for visualizing them. The manifests for this section are in the `/20-productionize-shopping-cart` directory.

**1. Install the Kube Prometheus Stack**

First, add the `prometheus-community` Helm repository:
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

Now, install the stack into a new `monitoring` namespace:
```bash
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring --create-namespace \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false
```

**2. Update the Backend Service for Monitoring**

The backend application already exposes a `/metrics` endpoint. We just need to update the `Service` to expose this port and add a label for Prometheus to find it.

Apply the updated backend service manifest from the shopping cart application directory:
```bash
# This manifest contains the updated service definition
kubectl apply -f 19-shopping-cart-app/backend.yaml
```

**3. Create a ServiceMonitor**

A `ServiceMonitor` tells Prometheus which services to monitor. Apply the `ServiceMonitor` manifest from the `/20-productionize-shopping-cart` directory:
```bash
kubectl apply -f 20-productionize-shopping-cart/servicemonitor.yaml
```
This monitor will now start scraping metrics from our backend service.

**4. Access Grafana via Ingress**

To access the Grafana dashboard, apply the Ingress manifest from the `/20-productionize-shopping-cart` directory:
```bash
kubectl apply -f 20-productionize-shopping-cart/grafana-ingress.yaml
```

Now, you can open your browser to `http://grafana.localtest.me`.

The default login credentials are:
- **Username:** `admin`
- **Password:** `prom-operator`

You can now explore the pre-built dashboards and see metrics from the shopping cart application.

## Concepts Covered

1.  **Pods**: The Smallest Unit
2.  **ReplicaSets**: Scaling Pods
3.  **Deployments**: The Workhorse
4.  **Services**: Networking Pods
5.  **ConfigMaps & Secrets**: External Configuration
6.  **Namespaces**: Logical Separation
7.  **Volumes & Persistent Volumes**: Data Persistence
8.  **StatefulSets**: For Stateful Apps
9.  **DaemonSets**: Node-specific Pods
10. **Jobs & CronJobs**: Batch and Scheduled Tasks
11. **Probes**: Health Checks
12. **Autoscaling**: Automatic Scaling
13. **Node Scheduling**: Controlling Pod Placement
14. **Network Policies**: Securing Pod Communication
15. **RBAC, Service Accounts & Quotas**: Security and Governance
16. **Ingress**: HTTP(S) Routing
17. **Custom Resources & Operators**: Extending Kubernetes
18. **Shopping Cart App**: A complete application example.
19. **Productionizing with Monitoring**: Setting up Prometheus and Grafana.

📝 Recap
We've now covered:

- **Workload objects:** Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronJob

- **Networking:** Service, Ingress, NetworkPolicy

- **Storage:** Volumes, PVCs, StatefulSets

- **Configuration:** ConfigMaps, Secrets, Namespaces

- **Resiliency:** Probes, Autoscaling, Affinity, Taints

- **Security & Governance:** RBAC, Service Accounts, Quotas

- **Extensibility:** CRDs & Operators

🎯 Next Steps
Practice YAMLs from this article in your own cluster.
Break things intentionally - delete pods, fail readiness checks, overload CPU - and observe how Kubernetes heals itself.

After reading this two-part series, you should feel comfortable with all the core Kubernetes concepts and be ready to tackle production-grade features.

## 🧹 Cluster Cleanup

When you are finished with the tutorials, you can delete the entire Kind cluster with the following command. This will remove the cluster and all the resources you created.

```bash
kind delete cluster --name kubernetes-playground
```