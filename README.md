> NOTE: This repository is currently in a state of flux as I finalize details of my cluster and slowly both learn and also move to different architectural patterns. In particular, the Helm and Terraform files will likely be drastically updated later as I migrate files and (eventually) bring Atlantis online for Terraform applying.

# GitOps

## 🔎 About

This repository contains Helm and Terraform files for declarative deployments for a home kubernetes cluster.

While it's meant to be run on Raspberry Pi devices, it should be equally valid anywhere Kubernetes can run.

## 🎖️ Features

- App-of-apps: A root Argo CD Application which manages child apps
- Namespaces: `argocd`, `cert-manager`, `kube-system`, `longhorn-system`, and `monitoring`
- Cert-manager: Jetstack Helm with CRDs + ClusterIssuers (staging/production) for Traefik HTTP-01
- Monitoring: Prometheus Operator with Grafana, using custom NVMe storage
- Argo CD UI: Externally-facing dashboard for controlling deployments and rollbacks
- Longhorn UI: Externally-facing dashboard for controlling the distributed block storage setup

## 🧱 Project Management

Remaining work in this repository can be found in this [Trello Kanban board](https://trello.com/b/HOJMq7WP/gitops).

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

## 🧐 Dashboard Access

TODO: Coming soon

## 🛠️ Built With

- [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
- [cert-manager](https://cert-manager.io/)
- [Grafana](https://grafana.com/)
- [Helm](https://helm.sh/docs/)
- [Kubernetes](https://kubernetes.io/) (and [k3s](https://k3s.io/))
- [Prometheus](https://prometheus.io/)
- [Terraform](https://developer.hashicorp.com/terraform)
- [Traefik](https://traefik.io/traefik)

## 📄 License

MIT License - You are welcome to fork this repository and use it to spin up your own home Kubernetes configurations.

## 🙇🏻‍♂️ Acknowledgements

- [Edede Oiwoh](https://github.com/ededejr) for inspiring me to build a home cluster and for bouncing ideas around
- [rpi4cluster.com](https://rpi4cluster.com/) for tips on GitOps with Raspberry Pi setups (even if the notes weren't current and Helm/Argo configurations weren't file-based)
- [Tesla](https://www.tesla.com/) for teaching me proper GitOps processes and giving me a chance to move mountains with them
