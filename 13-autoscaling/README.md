# 13 - Horizontal Pod Autoscaler (HPA)

This section demonstrates how to use the Horizontal Pod Autoscaler to automatically scale the number of pods in a deployment based on observed CPU utilization.

## Prerequisites

The HPA requires a metrics server to be installed in the cluster to collect resource metrics from pods. Our automated `start.sh` script installs the `kube-prometheus-stack`, which includes a compatible metrics server.

## 1. Deploy a Target Application

First, we need a deployment to autoscale. The `php-apache-deployment.yaml` manifest deploys a simple PHP application that is useful for demonstrating CPU-based autoscaling.

Note that we have set CPU *requests* on the container. This is a requirement for the HPA to work.

```bash
kubectl apply -f 13-autoscaling/php-apache-deployment.yaml
```

## 2. Create the HPA

Now, we create the `hpa.yaml` resource. This HPA targets our `php-apache` deployment and is configured to maintain an average CPU utilization of 50% across all pods. It will scale the deployment between 1 and 10 replicas.

```bash
kubectl apply -f 13-autoscaling/hpa.yaml
```

## 3. Observe the HPA

You can watch the HPA in action:

```bash
kubectl get hpa -w
```

Initially, the CPU utilization will be `<unknown>` or `0%`.

## 4. Generate Load

To trigger the scaling, we need to generate CPU load on the pods. We can do this by running a load-generating pod and hitting the service endpoint.

```bash
# Run a temporary pod to generate load
kubectl run -i --tty load-generator --rm --image=busybox:1.35 -- /bin/sh

# Inside the load-generator shell, run this loop:
while true; do wget -q -O- http://php-apache; done
```

Open a new terminal and watch the HPA. You will see the CPU utilization climb, and once it passes the 50% target, the HPA will increase the number of replicas. When you stop the load generator, the replica count will scale back down to 1.
