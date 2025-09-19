# Ingress

An Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Traffic routing is controlled by rules defined on the Ingress resource.

## Deploying an Ingress Controller

Before you can use Ingress resources, you need to have an Ingress controller running in your cluster. We will use the popular NGINX Ingress Controller.

You can deploy it with the following command for Kind:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

Wait a bit for the controller to be deployed:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

## Creating an Ingress Resource

Now you can create an Ingress resource. The following Ingress resource will route traffic to our `nginx-service` from the services examples. You'll need to have that service running.
