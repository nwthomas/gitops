provider "kubernetes" {
  # This is the path for K3s, not for full K8s
  config_path = "/etc/rancher/k3s/k3s.yaml"
}
