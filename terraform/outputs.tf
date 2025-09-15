output "namespaces" {
  description = "Created Kubernetes namespaces"
  value = {
    applications     = kubernetes_namespace.applications.metadata[0].name
    argocd          = kubernetes_namespace.argocd.metadata[0].name
    atlantis        = kubernetes_namespace.atlantis.metadata[0].name
    cert_manager    = kubernetes_namespace.cert_manager.metadata[0].name
    kube_system     = kubernetes_namespace.kube_system.metadata[0].name
    logging         = kubernetes_namespace.logging.metadata[0].name
    longhorn_system = kubernetes_namespace.longhorn_system.metadata[0].name
    monitoring      = kubernetes_namespace.monitoring.metadata[0].name
  }
}

output "storage_classes" {
  description = "Created Kubernetes storage classes"
  value = {
    longhorn_default         = kubernetes_storage_class.longhorn_default.metadata[0].name
    longhorn_high_availability = kubernetes_storage_class.longhorn_high_availability.metadata[0].name
    longhorn_fast           = kubernetes_storage_class.longhorn_fast.metadata[0].name
    longhorn_retain         = kubernetes_storage_class.longhorn_retain.metadata[0].name
  }
}

output "cluster_info" {
  description = "Cluster information"
  value = {
    environment  = var.environment
    cluster_name = var.cluster_name
    managed_by   = var.managed_by
  }
}
