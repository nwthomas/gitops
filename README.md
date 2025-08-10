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

## 🧱 Project Management

Remaining work in this repository can be found in this [Trello Kanban board](https://trello.com/b/HOJMq7WP/gitops).

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

## 🧐 Dashboard Access

Until the internal ingress is setup up, it's necessary to port forward on the Raspberry Pis while tunneling into them with SSH. Use these commands to access dashboards:

```
# For ArgoCD
# 1. SSH:
ssh -L 8080:localhost:8080 <PI_USERNAME>@<PI_IP_ADDRESS>
# 2. On device:
kubectl port-forward svc/argocd-server -n argocd 8080:443

# For Grafana
# 1. SSH:
ssh -L 3000:localhost:3000 <PI_USERNAME>@<PI_IP_ADDRESS>
# 2. On device:
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:443
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
