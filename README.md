> NOTE: This repository is currently in a state of flux as I finalize details of my cluster and slowly both learn and also move to different architectural patterns. In particular, the Helm and Terraform files will likely be drastically updated later as I migrate files and (eventually) bring Atlantis online for Terraform applying.

# GitOps

## 🔎 About

This repository contains ArgoCD, Helm, and Terraform files for declarative deployments with [Kubernetes](https://kubernetes.io/), specifically [k3s](https://k3s.io/).

You can use these files to stand up your own on-prem Kubernetes cluster. While this repository was built to be run on Raspberry Pi devices, it should be equally valid anywhere Kubernetes can run.

## 🎖️ Features

- App-of-apps: A root Argo CD Application deployment schema which recursively manages child apps
- Namespace deployments: `argocd`, `cert-manager`, `kube-system`, `logging`, `longhorn-system`, and `monitoring`
- Cert-manager: X.509 certificate management for Kubernetes
- Longhorn: Distributed on-prem file storage
- Metal LB: An on-prem native software load balancer
- Monitoring: Prometheus Operator with Grafana using storage PVC through Longhorn
- Dashboard UI for:
    - Argo CD: For controlling deployments and rollbacks
    - Grafana: For building dashboards against Prometheus data
    - Longhorn: For controlling the distributed block storage setup
    - Prometheus: For querying against raw data from pods/nodes/deployment resources

## 🧱 Project Management

Work for this repository is house in this [Trello board](https://trello.com/b/HOJMq7WP/gitops).

## 📁 Project Structure

```bash
├── argocd/                                      # ArgoCD application definitions
│   ├── apps/                                    # Individual application manifests
│   │   ├── argocd/                              # ArgoCD self-management
│   │   ├── cert-manager/                        # Certificate management
│   │   ├── kube-system/                         # Core system components
│   │   ├── longhorn-system/                     # Storage management
│   │   └── monitoring/                          # Monitoring stack
│   ├── namespaces/                              # Namespace management
│   └── root/                                    # Root application
├── helm/                                        # Helm charts
│   ├── argocd/                                  # ArgoCD Helm chart
│   ├── cert-manager/                            # Cert-manager ClusterIssuers
│   ├── longhorn/                                # Longhorn storage
│   ├── prometheus/                              # Prometheus monitoring
│   └── servicemonitors/                         # Service monitors
└── terraform/
    ├── namespaces.tf                            # Namespace definitions
    └── provider.tf                              # Terraform provider configuration
```

## 🛠️ Built With

### Hardware

The cluster this repo's files runs on uses Raspberry Pi 5 devices, specifically the 16gb version.

Here's the hardware list of what each of the control/worker nodes is using:
1. [Raspberry Pi 5](https://www.amazon.com/dp/B0DSPYPKRG)
2. [NVMe + POE+ Pi 5 Hat and Active Cooler](https://www.amazon.com/dp/B0D8JC3MXQ)
3. [Samsung 2TB NVMe SSD](https://www.amazon.com/dp/B0DHLCRF91)
4. [256gb Micro SD Card](https://www.amazon.com/dp/B08TJZDJ4D)

### Software

- [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
- [Cert Manager](https://cert-manager.io/)
- [Grafana](https://grafana.com/)
- [Grafana Loki](https://grafana.com/docs/loki/latest/)
- [Grafana Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) (soon to be removed for Grafana Alloy)
- [Helm](https://helm.sh/docs/)
- [Kubernetes](https://kubernetes.io/), specifically [K3s](https://k3s.io/)
- [Longhorn](https://longhorn.io/)
- [Metal LB](https://metallb.io/)
- [OpenFaaS](https://www.openfaas.com/) (coming soon)
- [Prometheus](https://prometheus.io/) (including Prometheus Operator)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Terraform](https://developer.hashicorp.com/terraform)
- [Traefik](https://traefik.io/traefik)

## 🙇🏻‍♂️ Acknowledgements

- [Edede Oiwoh](https://github.com/ededejr) for inspiring me to build a home cluster and for bouncing ideas around
- [rpi4cluster.com](https://rpi4cluster.com/) for tips on GitOps with Raspberry Pi setups (even if the notes weren't current and Helm/Argo configurations weren't file-based)
- [Tesla](https://www.tesla.com/) for teaching me proper GitOps processes and giving me a chance to move mountains with them
- [gitops-patterns repository](https://github.com/cloudogu/gitops-patterns) for what will likely be ongoing sources of truth for modern architecture patterns