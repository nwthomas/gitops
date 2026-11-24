terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 3.0"
    }
  }

}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
