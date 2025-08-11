# GitOps Repository

This repository follows a GitOps approach with clear separation of concerns across different directories.

## Repository Structure

```
gitops/
├── argocd/                 # ArgoCD applications and configurations
│   ├── apps/              # Application definitions
│   ├── namespaces/        # Namespace definitions
│   └── root/              # Root application
├── helm/                  # Helm charts
│   ├── cert-manager/      # Cert-manager ClusterIssuers chart
│   └── README.md
├── terraform/             # Terraform infrastructure code
│   ├── namespaces.tf
│   └── provider.tf
└── README.md
```

## Directory Purposes

### `argocd/`

Contains all ArgoCD-related configurations:

- **apps/**: Individual ArgoCD Application resources
- **namespaces/**: Namespace definitions for ArgoCD
- **root/**: Root application that manages other applications

### `helm/`

Contains all Helm charts used by the GitOps workflow:

- Charts are referenced by ArgoCD applications
- Each chart can have environment-specific values
- Charts can be tested independently

### `terraform/`

Contains infrastructure as code:

- Kubernetes cluster provisioning
- Namespace creation
- Other infrastructure resources

## Benefits of This Structure

1. **Clear Separation**: Each tool has its own directory
2. **Reusability**: Helm charts can be used by multiple ArgoCD apps
3. **Maintainability**: Easy to find and modify specific components
4. **Testing**: Each component can be tested independently
5. **Documentation**: Clear structure for documentation

## Workflow

1. **Infrastructure**: Terraform provisions the cluster and namespaces
2. **Applications**: ArgoCD deploys applications using Helm charts
3. **Configuration**: Helm charts provide templated configurations

## Getting Started

1. Review the documentation in each directory
2. Update repository URLs in ArgoCD applications
3. Customize values for your environment
4. Apply ArgoCD applications to your cluster
