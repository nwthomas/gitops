# GitOps

## 🔎 About

This repository contains Helm and Terraform files for declarative deployments for a home kubernetes cluster.

While it's meant to be run on a Raspberry Pi, it should be equally valid anywhere Kubernetes can run.

## 🎖️ Features

- App-of-apps: A root Argo CD Application which manages child apps
- Namespaces: `applications-eng`, `applications-prd`, `argocd`, `cert-manager`, `monitoring`
- Cert-manager: Jetstack Helm with CRDs + ClusterIssuers (staging/production) for Traefik HTTP-01
- Monitoring: Prometheus Operator with Grafana, using custom NVMe storage
- Argo CD UI ingress: Traefik with IP allowlist middleware and cert-manager TLS

## 📁 Project Structure

```
├── argocd/                              #
│   ├── apps/                            #
│   │   ├── applications-eng/            #
│   │   │   └── whoami-app.yaml          # Temporary placeholder
│   │   ├── applications-prd/            #
│   │   │   └── whoami-app.yaml          # Temporary placeholder
│   │   ├── argocd/                      #
│   │   │   └── argocd-ingress-app.yaml  #
│   │   ├── cert-manager/                #
│   │   │   └── cert-manager.yaml        #
│   │   └── monitoring/                  #
│   │       ├── prometheus-app.yaml      # Prometheus Operator with Grafana
│   │       ├── prometheus-crds.yaml     # Prometheus Operator CRDs
│   │       ├── prometheus-crds-app.yaml # ArgoCD app for CRDs
│   │       ├── nvme-storageclass.yaml   # Custom NVMe storage configuration
│   │       └── nvme-storage-app.yaml    # ArgoCD app for NVMe storage
│   ├── namespaces/                      #
│   │   ├── applications-eng-app.yaml    #
│   │   ├── applications-prd-app.yaml    #
│   │   ├── argocd-app.yaml              #
│   │   ├── cert-manager-app.yaml        #
│   │   └── monitoring-app.yaml          #
│   └── root/                            #
│       └── root-app.yaml                #
└── terraform/                           #
    ├── namespaces.tf                    #
    └── provider.tf                      #
```

## 🛠️ Built With

- [Argo CD](https://argo-cd.readthedocs.io/en/stable/)
- [cert-manager](https://cert-manager.io/)
- [Helm](https://helm.sh/docs/)
- [Kubernetes](https://kubernetes.io/) (and [k3s](https://k3s.io/))
- [Terraform](https://developer.hashicorp.com/terraform)
- [Traefik](https://traefik.io/traefik)

## 📄 License

MIT License - You are welcome to fork this repository and use it to spin up your own home Kubernetes configurations.

## 🙇🏻‍♂️ Acknowledgements

- [Tesla](https://www.tesla.com/) for teaching me proper GitOps processes and giving me a chance to move mountains with them
- [rpi4cluster.com](https://rpi4cluster.com/) for various tips on GitOps with Raspberry Pi setups (even if the notes there weren't always current)
