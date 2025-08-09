# GitOps

## 🔎 About

This repository contains Helm and Terraform files for declarative deployments for a home kubernetes cluster.

While it's meant to be run on a Raspberry Pi, it should be equally valid anywhere Kubernetes can run.

## 🎖️ Features

- App-of-apps: A root Argo CD Application which manages child apps
- Namespaces: `argocd`, `cert-manager`, `applications-eng`, `applications-prd`
- Cert-manager: Jetstack Helm with CRDs + ClusterIssuers (staging/production) for Traefik HTTP-01
- Argo CD UI ingress: Traefik with IP allowlist middleware and cert-manager TLS

## 📁 Project Structure

```
├── argocd/
│   ├── apps/
│   │   ├── applications-eng/
│   │   │   └── whoami-app.yaml # Temporary placeholder
│   │   ├── applications-prd/
│   │   │   └── whoami-app.yaml # Temporary placeholder
│   │   ├── argo/
│   │   │   └── argocd-ingress-app.yaml
│   │   └── cert-manager/
│   │   │   └── cert-manager.yaml
│   ├── namespaces/
│   │   ├── applications-eng-app.yaml
│   │   ├── applications-prd-app.yaml
│   │   ├── argocd-app.yaml
│   │   └── cert-manager-app.yaml
│   └── root/
│       └── root-app.yaml
├── terraform/
│   ├── namespaces.tf
│   └── provider.tf
└── README.md
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
