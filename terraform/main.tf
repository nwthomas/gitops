# Main Terraform configuration for Kubernetes infrastructure
# This file serves as the entry point and can be used to organize resources

# Local values for common configurations
locals {
  common_labels = {
    "app.kubernetes.io/managed-by" = var.managed_by
    "environment"                  = var.environment
    "cluster"                      = var.cluster_name
    "terraform"                    = "true"
  }
  
  # Longhorn parameters that are common across storage classes
  longhorn_common_params = {
    "staleReplicaTimeout" = tostring(var.longhorn_stale_replica_timeout)
    "fromBackup"          = ""
    "fsType"              = var.longhorn_fs_type
  }
}
