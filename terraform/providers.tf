terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.2-rc10"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "0.11.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.3.0"
    }
  }
}

provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_tls_insecure = true # By default Proxmox Virtual Environment uses self-signed certificates.
}

provider "talos" {}

provider "helm" {
  kubernetes = {
    config_path = "./kubeconfig"
  }
}