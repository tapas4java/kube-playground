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
3. Run the `exit` when you are done:
    ```bash
    exit
    ```

This will drop you into a shell and automatically trigger the `start.sh` script. This script will:
1.  Create a multi-node Kind cluster running Kubernetes v1.29.2.
2.  Install the Kubernetes Metrics Server (for resource metrics in Headlamp).
3.  Install the NGINX Ingress controller.
4.  Install the Headlamp dashboard.

Once the script is finished, your environment is ready! It will print the login token for the Headlamp dashboard.

You can access the Headlamp dashboard at `http://headlamp.localtest.me`. Copy the token from your terminal and paste it into the login screen.

When you are ready to stop, you can type `exit` in your terminal to leave the Devbox shell. This will automatically trigger the cleanup process.

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

The `/19-shopping-cart-app` directory contains the Google microservices demo, a fully functional, multi-tier application that demonstrates how various Kubernetes resources work together in a realistic scenario.

> **Note:** This application is sourced from the official [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo) repository.

**Application Architecture:**

This application is composed of many microservices written in different languages that talk to each other over gRPC. It includes services for a frontend, product catalog, cart, checkout, and more.

**How to Deploy:**

1.  Make sure you are in the root of the repository.
2.  Apply all the manifests in the `19-shopping-cart-app` directory. This will deploy all the microservices and the Ingress to expose the application.
    ```bash
    kubectl apply -f 19-shopping-cart-app/
    ```
3.  Verify that all the pods are running:
    ```bash
    kubectl get pods
    ```
    You should see pods for all the different microservices. This may take a few minutes to start up.

**How to Access:**

You can now access the shopping cart application at `http://shop.localtest.me`.

### 🏭 Productionizing the App with Full Observability

The final step is to install a complete observability stack. This will give you visibility into the three pillars of observability: **metrics**, **logs**, and **traces**. We will use a combination of popular open-source tools from the Grafana ecosystem.

The manifests for this section are in the `/20-productionize-shopping-cart` directory.

**1. Install Prometheus for Metrics**

We'll use the `kube-prometheus-stack` Helm chart, which includes Prometheus for collecting metrics and Grafana for dashboards.

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

**2. Configure ServiceMonitors for Key Services**

`ServiceMonitor`s tell Prometheus which services to monitor. Apply the manifest from the `/20-productionize-shopping-cart` directory to monitor the `frontend`, `checkout`, and `recommendation` services.
```bash
kubectl apply -f 20-productionize-shopping-cart/servicemonitors.yaml
```

**3. Install Loki for Logging**

Next, we'll install Grafana Loki, a powerful log aggregation system. We will use the `loki-stack` chart, which includes Loki for the backend and Promtail as the agent to collect logs from all pods.

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack --namespace monitoring
```

**4. Install Tempo for Tracing**

Finally, we'll install Grafana Tempo for distributed tracing. But first, we need to enable tracing in the demo application.

The application's deployments have tracing disabled by default. Open the `19-shopping-cart-app/google-microservices-demo.yaml` file and change all instances of `DISABLE_TRACING` from `"1"` to `"0"`.

Now, install Tempo:
```bash
helm install tempo grafana/tempo --namespace monitoring
```

**5. Access Grafana for All Observability Data**

To access the Grafana dashboard, apply the Ingress manifest:
```bash
kubectl apply -f 20-productionize-shopping-cart/grafana-ingress.yaml
```

Now, you can open your browser to `http://grafana.localtest.me`.

The default login credentials are:
- **Username:** `admin`
- **Password:** `prom-operator`

Inside Grafana, you can now explore:
- **Metrics** from your services in the pre-built dashboards.
- **Logs** by navigating to the "Explore" view and selecting the "Loki" data source.
- **Traces** by navigating to the "Explore" view and selecting the "Tempo" data source.

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
19. **Productionizing with Observability**: Setting up metrics, logs, and traces.

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

When you are finished with the tutorials, you can simply exit the Devbox shell by typing `exit`.

This will automatically trigger the `stop.sh` script, which deletes the Kind cluster and all its resources, leaving your system clean.
