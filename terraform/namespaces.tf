locals {
  environments = ["eng", "prd"]
  namespaces = {
    argocd        = "argocd"
    monitoring    = "monitoring"
    cert_manager  = "cert-manager"
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = local.namespaces.argocd
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

resource "kubernetes_namespace" "environments" {
  for_each = toset(local.environments)
  
  metadata {
    name = each.key
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment" = each.key
    }
  }
}

resource "kubernetes_namespace" "services" {
  for_each = { for pair in setproduct(local.environments, keys(local.namespaces)) : "${pair[1]}-${pair[0]}" => {
    env = pair[0]
    namespace = local.namespaces[pair[1]]
  } if pair[1] != "argocd" }

  metadata {
    name = "${each.value.namespace}-${each.value.env}"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "environment" = each.value.env
    }
  }
}
