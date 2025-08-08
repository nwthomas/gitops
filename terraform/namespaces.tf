resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}
