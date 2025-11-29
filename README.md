> NOTE: Terraform files will be drastically updated later as [Atlantis](https://www.runatlantis.io) is brought online.

# GitOps 🛠️

## About

This repository contains ArgoCD, Helm, and Terraform files for declarative deployments with [Kubernetes](https://kubernetes.io/), specifically [k3s](https://k3s.io/).

You can use these files to stand up your own on-prem Kubernetes cluster. While this repository was built to be run on Raspberry Pi devices, it should be equally valid anywhere Kubernetes can run.

If you want to implement this for yourself, please follow the [setup document](./docs/SETUP.md) (which is actively being updated).

## Features

- App-of-apps: A root Argo CD Application deployment schema which recursively manages child apps
- Namespace deployments: `argocd`, `cert-manager`, `kube-system`, `logging`, `longhorn-system`, `monitoring`, and `applications-eng`
- Cert-manager: X.509 certificate management for Kubernetes
- Longhorn: Distributed on-prem file storage with multiple storage classes
- Metal LB: An on-prem native software load balancer
- Monitoring: Prometheus Operator with Grafana using storage PVC through Longhorn
- n8n: Workflow automation platform with persistent storage
- vLLM: Runtime for AI models on a GPU node
- Dashboard UI for:
  - Argo CD: Controlling deployments and rollbacks
  - Grafana: Building dashboards against Prometheus data
  - Longhorn: Controlling the distributed block storage setup
  - n8n: Creating and managing automated workflows
  - Open WebUI: A ChatGPT-like interface paired with the vLLM deployment for inference
  - Prometheus: Querying against raw data from pods/nodes/deployment resources

## Project Management

Work for this repository is housed in this [Trello board](https://trello.com/b/HOJMq7WP/gitops).

## Project Structure

```bash
├── argocd/                                      # ArgoCD application definitions
│   ├── apps/                                    # Application-level deployments
│   │   ├── applications/                        #
│   │   ├── argocd/                              #
│   │   ├── cert-manager/                        #
│   │   ├── kube-system/                         #
│   │   ├── logging/                             #
│   │   ├── longhorn-system/                     #
│   │   └── monitoring/                          #
│   ├── namespaces/                              # Namespace-level deployments
│   └── root/                                    # Root ArgoCD application deployment
├── helm/                                        # Helm charts
│   ├── argocd/                                  #
│   ├── cert-manager/                            #
│   ├── grafana/                                 #
│   ├── longhorn/                                #
│   ├── n8n/                                     #
│   ├── nvidia-device-plugin/                    #
│   ├── open-webui/                              #
│   ├── prometheus/                              #
│   ├── prometheus-operator/                     #
│   ├── prometheus-service-monitors/             #
│   ├── vllm/                                    #
└── terraform/                                   # Terraform configurations
    ├── namespaces.tf                            # Kubernetes namespace definitions
    ├── provider.tf                              # Terraform provider configuration
    └── storage-classes.tf                       # Longhorn storage class definitions
```

## Built With

### Hardware

The cluster this repo's files runs on uses Raspberry Pi 5 devices, specifically the 16gb version.

Here's the hardware list of what each of the control/worker nodes is using:

1. [Raspberry Pi 5](https://amzn.to/4ps5tiR)
2. [NVMe + POE+ Pi 5 Hat and Active Cooler](https://amzn.to/49HdXNT)
3. [Samsung 2TB NVMe SSD](https://amzn.to/4onuB8Q)
4. [256gb Micro SD Card](https://amzn.to/3MtUpCU)

The GPU node I am running for model inference is quite different and uses the following hardware:

1. [Ncase M3 Case](https://ncased.com/products/m3-round?srsltid=AfmBOoqQs1S0VUqh8MdMqWYxuy4zGDsMXjRNd5H4PEKTIi_6S1WMy2WY)
2. [MSI B650I Edge Wifi Motherboard](https://amzn.to/4rqMshN)
3. [AMD 9800x3D CPU](https://amzn.to/3K04gQk)
4. [128gb DDR5 Corsair RAM](https://amzn.to/489KtXV)
5. [8TB Western Digital NVMe SSD](https://amzn.to/49OdUju)
6. [Nvidia RTX 6000 Pro Workstation GPU](https://amzn.to/4amKZTJ)
7. [Corsair SF1000 PSU](https://amzn.to/4okJn05)
8. [NZXT Kraken Elite 280mm AIO](https://amzn.to/4okXBxZ)
9. [Noctua 120mm Fans](https://amzn.to/4okXBxZ)

I built it to be beefy enough to handle inference but also lightweight enough for me to unplug, take with me while traveling, and use as a personal computer.

### Software

- [Argo CD](https://argo-cd.readthedocs.io/en/stable)
- [Cert Manager](https://cert-manager.io)
- [Grafana](https://grafana.com)
- [Grafana Loki](https://grafana.com/docs/loki/latest)
- [Grafana Promtail](https://grafana.com/docs/loki/latest/send-data/promtail)
- [Helm](https://helm.sh/docs)
- [Kubernetes](https://kubernetes.io)/[K3s](https://k3s.io)
- [Longhorn](https://longhorn.io)
- [Metal LB](https://metallb.io)
- [n8n](https://n8n.io)
- [Nvidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/index.html)
- [Open WebUI](https://openwebui.com)
- [OpenFaaS](https://www.openfaas.com) (coming soon)
- [Prometheus](https://prometheus.io)
- [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator)
- [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets)
- [Terraform](https://developer.hashicorp.com/terraform)
- [Traefik](https://traefik.io/traefik)
- [vLLM](https://docs.vllm.ai)

## Acknowledgements

- [Edede Oiwoh](https://github.com/ededejr) for inspiring me to build a home cluster and for bouncing ideas around
- [rpi4cluster.com](https://rpi4cluster.com/) for tips on GitOps with Raspberry Pi setups (even if the notes weren't current and Helm/Argo configurations weren't file-based)
- [Twitter](https://x.com) (now X), [Loom](https://www.loom.com/), and [Tesla](https://www.tesla.com/) for teaching me proper GitOps processes and giving me a chance to move mountains with them
