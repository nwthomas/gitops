resource "kubernetes_namespace" "applications" {
  metadata {
    name = "applications"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "atlantis" {
  metadata {
    name = "atlantis"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "kube_system" {
  metadata {
    name = "kube-system"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "logging" {
  metadata {
    name = "logging"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "longhorn_system" {
  metadata {
    name = "longhorn-system"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
}
