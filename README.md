# Mastering Kubernetes with Kube-Playground

> 💡 **Easiest Way to Start:** This repository is configured with [Devbox](#-quick-start-with-devbox) to instantly create a complete Kubernetes learning environment with `kind`, `kubectl`, `helm`, and all other tools pre-installed. Just run `devbox shell` to begin!

![Kube Playground](./kube-playground.png)

This repository is a hands-on playground for learning Kubernetes.

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
1.  Create a multi-node Kind cluster running Kubernetes v1.34.0.
2.  Install the NGINX Ingress controller.
3.  Install the Headlamp dashboard.

Once the script is finished, your environment is ready! It will print the login token for the Headlamp dashboard.

You can access the Headlamp dashboard at `http://headlamp.localtest.me`. Copy the token from your terminal and paste it into the login screen.

When you are ready to stop, you can type `exit` in your terminal to leave the Devbox shell. This will automatically trigger the cleanup process.

## Repository Structure

The repository is organized by Kubernetes concepts, with each directory containing the relevant manifests and instructions.

-   `/01-cluster-setup`: Contains all the configuration for the automated environment setup. To see how the environment is created, you can inspect the `start.sh` script and the manifests in this directory.

-   `/02-namespaces`: Namespaces are used to create logical partitions of the cluster. The `namespaces.yaml` file shows how to create `dev` and `prod` namespaces.

-   `/03-pods`: Pods are the smallest deployable units in Kubernetes. We have a basic `nginx-pod.yaml` and a `pod-with-multicontainer.yaml` to show a more complex pod with shared volumes.

-   `/04-replicasets`: A ReplicaSet ensures that a specified number of pod replicas are running at any given time. While not often used directly, they are the basis for Deployments. See `nginx-rs.yaml`.

-   `/05-deployments`: Deployments are the standard way to manage stateless applications. They handle rolling updates and rollbacks. The `nginx-deploy.yaml` provides a basic example, while `deployment-strategies.yaml` demonstrates the difference between `RollingUpdate` and `Recreate` strategies.

-   `/06-services`: Services provide stable network endpoints for pods. We cover four types: `nginx-service-clusterip.yaml` (internal), `nginx-service-nodeport.yaml` (exposes on node), `nginx-service-loadbalancer.yaml` (uses cloud provider LB), and `externalname-service.yaml` (maps to an external DNS name).

-   `/07-configmaps-secrets`: These resources externalize configuration. We show how to create a `configmap.yaml` and `secret.yaml`, and then how to consume them as environment variables (`pod-with-env.yaml`) or as mounted files (`pod-with-volume-mounts.yaml`).

-   `/08-volumes`: Volumes provide data persistence beyond a container's lifecycle. We show a temporary `pod-with-emptydir.yaml` and a persistent example using `pvc.yaml` (the claim) and `pod-with-pvc.yaml` (the consumer).

-   `/09-statefulsets`: For stateful applications, a `statefulset.yaml` provides stable network identifiers and persistent storage. Our example uses Redis and its required `redis-headless-service.yaml`.

-   `/10-daemonsets`: DaemonSets ensure that all (or some) nodes run a copy of a pod. This is useful for log collectors or monitoring agents. See `daemonset.yaml`.

-   `/11-jobs-cronjobs`: For batch processing, a `job.yaml` runs a task to completion. A `cronjob.yaml` runs a job on a schedule. We also include a `parallel-job.yaml` to show how multiple pods can work on a task.

-   `/12-probes`: Probes are used for health checking. The `deployment-with-probes.yaml` example now includes `livenessProbe`, `readinessProbe`, and `startupProbe` to ensure container health.

-   `/13-autoscaling`: The Horizontal Pod Autoscaler (HPA) automatically scales the number of pods. See the `README.md` in this folder for a full walkthrough using the `hpa.yaml` and `php-apache-deployment.yaml`.

-   `/14-scheduling`: Control where your pods run. `node-affinity-pod.yaml` schedules pods based on node labels, `taints-and-tolerations/` forces pods to have tolerations to run on a tainted node, and `pod-affinity-pod.yaml` schedules pods based on the location of other pods.

-   `/15-network-policies`: Network Policies control traffic flow between pods. We provide an example of allowing traffic between a `frontend.yaml` and a `backend.yaml` with `backend-policy.yaml`, and also a `default-deny-policy.yaml` for a more secure posture.

-   `/16-rbac`: Role-Based Access Control manages permissions. `rbac.yaml` shows a `Role` and `RoleBinding` (namespaced), while `clusterrole.yaml` shows a `ClusterRole` and `ClusterRoleBinding` (cluster-wide). Other examples include `pod-with-sa.yaml` and `resource-quota.yaml`.

-   `/17-ingress`: Ingress manages external access to services, typically HTTP. `ingress.yaml` shows basic host-based routing, and `tls-ingress.yaml` demonstrates how to secure it with a TLS certificate.

-   `/18-custom-resources`: Extend the Kubernetes API by creating your own resources with a `crd.yaml` (Custom Resource Definition) and then creating instances of it like `foo-resource.yaml`.

-   `/19-resource-requests-and-limits`: Managing resource requests and limits.

-   `/20-shopping-cart-app`: A complete shopping cart application.

### 🛍️ Example Application: Shopping Cart

The `/20-shopping-cart-app` directory contains the Google microservices demo, a fully functional, multi-tier application that demonstrates how various Kubernetes resources work together in a realistic scenario.

> **Note:** This application is sourced from the official [GoogleCloudPlatform/microservices-demo](https://github.com/GoogleCloudPlatform/microservices-demo) repository.

**How to Deploy:**

1.  Make sure you are in the root of the repository.
2.  Apply all the manifests in the `20-shopping-cart-app` directory. This will deploy all the microservices and the Ingress to expose the application.
    ```bash
    kubectl apply -f 20-shopping-cart-app/
    ```
3.  Verify that all the pods are running:
    ```bash
    kubectl get pods
    ```

**How to Access:**

You can now access the shopping cart application at `http://shop.localtest.me`.

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
18. **Resource Requests & Limits**: Managing pod resources.
19. **Shopping Cart App**: A complete microservices demo application example.

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
