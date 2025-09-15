variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "k3s-cluster"
}

variable "managed_by" {
  description = "Label value for app.kubernetes.io/managed-by"
  type        = string
  default     = "terraform"
}

variable "longhorn_replicas" {
  description = "Default number of replicas for Longhorn storage class"
  type        = number
  default     = 3
}

variable "longhorn_ha_replicas" {
  description = "Number of replicas for Longhorn HA storage class"
  type        = number
  default     = 6
}

variable "longhorn_fast_replicas" {
  description = "Number of replicas for Longhorn fast storage class"
  type        = number
  default     = 2
}

variable "longhorn_stale_replica_timeout" {
  description = "Stale replica timeout in minutes for Longhorn"
  type        = number
  default     = 2880
}

variable "longhorn_fs_type" {
  description = "Filesystem type for Longhorn volumes"
  type        = string
  default     = "ext4"
}
