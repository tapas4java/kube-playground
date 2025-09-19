# Horizontal Pod Autoscaling (HPA)

The Horizontal Pod Autoscaler automatically scales the number of pods in a replication controller, deployment, replica set or stateful set based on observed CPU utilization.

## Prerequisites

To use the HPA, you need to have a metrics server deployed in your cluster. If you are using Minikube, you can enable it with:

```bash
minikube addons enable metrics-server
```

## Creating the HPA

First, you need a deployment to autoscale. We can use the `nginx-deploy` deployment we created earlier.

To create an HPA for the `nginx-deploy` deployment, run the following command:

```bash
kubectl autoscale deployment nginx-deploy --cpu-percent=50 --min=1 --max=5
```

This command creates an HPA that targets 50% CPU utilization for the pods in the `nginx-deploy` deployment. The HPA will scale the number of pods between 1 and 5.

## Observing the HPA

You can watch the HPA with the following command:

```bash
kubectl get hpa --watch
```

To generate load and see the HPA in action, you can run a temporary pod and send a flood of requests to the nginx service.

```bash
# Make sure you have the nginx-service from the services examples running
kubectl run -i --tty load-generator --rm --image=busybox --restart=Never -- /bin/sh -c "while sleep 0.01; do wget -q -O- http://nginx-service; done"
```

You should see the HPA scale up the number of nginx pods as the CPU utilization increases. When you stop the load generator, the HPA will scale the deployment back down.

