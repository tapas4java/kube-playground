# Taints and Tolerations

Taints and tolerations are a mechanism in Kubernetes that allows you to ensure that pods are not placed on inappropriate nodes.

## Tainting a Node

First, you need to taint a node. You can do this with the `kubectl taint` command. For example, to taint a node named `kind-control-plane` with the key `app`, value `blue`, and the `NoSchedule` effect, you would run:

```bash
kubectl taint nodes kind-control-plane app=blue:NoSchedule
```

The `NoSchedule` effect means that no new pods will be scheduled on this node unless they have a matching toleration.

## Pod with a Toleration

Now, you can create a pod with a toleration that matches the taint. This pod will be able to be scheduled on the tainted node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod-with-toleration
spec:
  containers:
  - name: my-app
    image: busybox
    command: ['sh', '-c', 'echo "Hello, Toleration!" && sleep 3600']
  tolerations:
  - key: "app"
    operator: "Equal"
    value: "blue"
    effect: "NoSchedule"
```
