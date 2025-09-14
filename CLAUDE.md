# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands

- **List Helm chart contents**: `helm template <chart-path>`
- **Install/Upgrade a chart**: `helm upgrade --install <name> <chart-path> --namespace <ns>`
- **Lint a chart**: `helm lint <chart-path>`
- **Validate Argo CD application**: `argocd app get <app-name>`
- **Sync Argo CD application**: `argocd app sync <app-name>`
- **Apply a kubectl manifest**: `kubectl apply -f <file>`
- **Delete a chart/namespace**: `helm uninstall <name> --namespace <ns>` or `kubectl delete namespace <ns>`
- **Terraform init & apply** (if enabled): `terraform init` then `terraform apply` within `terraform/`
- **View logs**: `kubectl logs -n <namespace> <pod>`

## High Level Architecture

- Root Argo CD application resides at `argocd/root/` and recursively manages child applications in `argocd/apps/*`.
- Each application deploys resources in dedicated namespaces (e.g., `cert-manager`, `longhorn-system`, `monitoring`).
- Helm charts under `helm/` provide the infrastructure components.
- Terraform configuration under `terraform/` is a work‑in‑progress but defines the underlying infrastructure provider.

## Working with Charts

- Helm chart directories contain: `Chart.yaml`, `values.yaml`, `templates/`.
- Use `helm dependency update` inside a chart directory if `requirements.yaml` or `Chart.yaml` dependencies are defined.
- Use `helm repo add` to add remote chart repositories referenced in values.

## Argo CD

- Argo CD resources are defined under `argocd/apps/`. Each app has a `spec` pointing to a Git repo and path.
- Sync state can be checked with `argocd app list`.

## Terraform (WIP)

- The directory `terraform/` contains `provider.tf` which specifies a provider.
- To apply, run `terraform init && terraform apply` inside this directory.

## Notes

- Some components (e.g., Longhorn) require manual installation steps via Helm and kubectl; see respective READMEs.
- Keep the cluster state separate from version control; use `secrets` and `sealed-secrets` for sensitive data.