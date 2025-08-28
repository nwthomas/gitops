# ArgoCD Helm Chart

This chart deploys ArgoCD using the official [argo-cd Helm chart](https://github.com/argoproj/argo-helm) as a dependency.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- ArgoCD CRDs (installed automatically by the chart)

## Installation

```bash
# Add the ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Install the chart
helm install argocd ./helm/argocd -n argocd --create-namespace
```

## Configuration

The following table lists the configurable parameters of the ArgoCD chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `argo-cd.server.service.type` | Service type for ArgoCD server | `ClusterIP` |
| `argo-cd.server.ingress.enabled` | Enable ingress for ArgoCD server | `false` |
| `argo-cd.controller.resources` | Resource limits for ArgoCD controller | `{requests: {cpu: 100m, memory: 128Mi}, limits: {cpu: 500m, memory: 512Mi}}` |
| `argo-cd.applicationSet.enabled` | Enable ApplicationSet controller | `true` |
| `argo-cd.rbac.create` | Create RBAC resources | `true` |
| `argo-cd.namespace.create` | Create namespace | `true` |
| `argo-cd.namespace.name` | Namespace name | `argocd` |

## Accessing ArgoCD

### Port Forward
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

### LoadBalancer
If you've configured a LoadBalancer service:
```bash
kubectl get svc argocd-server -n argocd
```

### Ingress
If you've configured ingress:
```bash
kubectl get ingress -n argocd
```

## Getting the Admin Password

```bash
kubectl -n argocd get secret argocd-server -o jsonpath="{.data.admin\.password}" | base64 -d
```

## Security Considerations

1. **Change the default admin password** after first login
2. **Configure RBAC** for proper access control
3. **Use sealed secrets** for sensitive configuration
4. **Enable SSO** with Dex for production environments

## High Availability

To enable high availability, uncomment the HA configuration in `values.yaml`:

```yaml
argo-cd:
  controller:
    replicas: 2
  repoServer:
    replicas: 2
  server:
    replicas: 2
```

## External Access

To enable external access via LoadBalancer, update the service configuration:

```yaml
argo-cd:
  server:
    service:
      type: LoadBalancer
      loadBalancerIP: "192.168.0.201"  # Your external IP
```

## Ingress Configuration

To enable ingress access:

```yaml
argo-cd:
  server:
    ingress:
      enabled: true
      ingressClassName: traefik
      hosts:
        - argocd.yourdomain.com
      tls:
        - secretName: argocd-tls
          hosts:
            - argocd.yourdomain.com
```

## Troubleshooting

### Check ArgoCD Status
```bash
kubectl get pods -n argocd
kubectl logs -n argocd deployment/argocd-server
```

### Check Application Status
```bash
kubectl get applications -n argocd
kubectl describe application <app-name> -n argocd
```

## Upgrading

```bash
helm upgrade argocd ./helm/argocd -n argocd
```

## Uninstalling

```bash
helm uninstall argocd -n argocd
kubectl delete namespace argocd
```

## Additional Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [ArgoCD Helm Chart](https://github.com/argoproj/argo-helm)
- [GitOps Best Practices](https://www.gitops.tech/)
