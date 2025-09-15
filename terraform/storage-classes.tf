resource "kubernetes_storage_class" "longhorn_default" {
  metadata {
    name = "longhorn"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = tostring(var.longhorn_replicas)
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
    "dataLocality"        = "disabled"
  }
}

resource "kubernetes_storage_class" "longhorn_high_availability" {
  metadata {
    name = "longhorn-ha"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = tostring(var.longhorn_ha_replicas)
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
    "dataLocality"        = "best-effort"
  }
}

resource "kubernetes_storage_class" "longhorn_fast" {
  metadata {
    name = "longhorn-fast"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = tostring(var.longhorn_fast_replicas)
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
    "dataLocality"        = "strict-local"
  }
}

resource "kubernetes_storage_class" "longhorn_retain" {
  metadata {
    name = "longhorn-retain"
    labels = {
      "app.kubernetes.io/managed-by" = var.managed_by
      "environment"                  = var.environment
      "cluster"                      = var.cluster_name
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = tostring(var.longhorn_replicas)
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
    "dataLocality"        = "disabled"
  }
}
