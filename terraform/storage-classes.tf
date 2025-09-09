resource "kubernetes_storage_class" "longhorn_default" {
  metadata {
    name = "longhorn"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = "3"
    "staleReplicaTimeout" = "2880"
    "fromBackup"          = ""
    "fsType"              = "ext4"
    "dataLocality"        = "disabled"
  }
}

resource "kubernetes_storage_class" "longhorn_high_availability" {
  metadata {
    name = "longhorn-ha"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = "6"
    "staleReplicaTimeout" = "2880"
    "fromBackup"          = ""
    "fsType"              = "ext4"
    "dataLocality"        = "best-effort"
  }
}

resource "kubernetes_storage_class" "longhorn_fast" {
  metadata {
    name = "longhorn-fast"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = "2"
    "staleReplicaTimeout" = "2880"
    "fromBackup"          = ""
    "fsType"              = "ext4"
    "dataLocality"        = "strict-local"
  }
}

resource "kubernetes_storage_class" "longhorn_retain" {
  metadata {
    name = "longhorn-retain"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  storage_provisioner    = "driver.longhorn.io"
  reclaim_policy         = "Retain"
  volume_binding_mode    = "Immediate"
  allow_volume_expansion = true
  
  parameters = {
    "numberOfReplicas"    = "3"
    "staleReplicaTimeout" = "2880"
    "fromBackup"          = ""
    "fsType"              = "ext4"
    "dataLocality"        = "disabled"
  }
}
