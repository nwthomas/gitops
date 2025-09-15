terraform {
  required_version = ">= 1.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  
  # Uncomment and configure backend for remote state management
  # backend "s3" {
  #   bucket = "your-terraform-state-bucket"
  #   key    = "kubernetes/terraform.tfstate"
  #   region = "us-west-2"
  # }
}

provider "kubernetes" {
  # This is the path for K3s, not for full K8s
  config_path = var.kubeconfig_path
}
