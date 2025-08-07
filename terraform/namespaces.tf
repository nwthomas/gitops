resource "kubernetes_namespace" "portainer" {
  metadata {
    name = "portainer-namespace-app"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd-namespace-app"
  }
}
