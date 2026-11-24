locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = var.managed_by
    "environment"                  = var.environment
    "cluster"                      = var.cluster_name
    "terraform"                    = "true"
  }

  longhorn_common_params = {
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
  }
}
