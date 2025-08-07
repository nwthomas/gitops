resource "kubernetes_namespace" "portainer" {
  metadata {
    name = "portainer"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}
