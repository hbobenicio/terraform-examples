# helm-provider-example

Demonstrates how to use the helm provider to install charts into a k8s cluster.

## Terraform Resources

This project manages basically 5 resources:

- Kubernetes Namespace
- A Nats helm release (from oficial nats helm chart)
- A Nats Streaming (stan) helm release (from oficial stan helm chart)
- A Prometheus helm release
- A Grafana helm release

## Kubectl cheatsheet

```
kubectl port-forward -n poc prometheus-server-78fffcd449-8666w 9090:9090
```

```
kubectl port-forward -n poc grafana-78fffcd449-8666w 3000:3000
```
