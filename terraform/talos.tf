locals {
  controlplane_ip  = proxmox_vm_qemu.nodes["controlplane"].default_ipv4_address
  cluster_endpoint = "https://${local.controlplane_ip}:6443"
  worker_ip_1      = proxmox_vm_qemu.nodes["worker1"].default_ipv4_address
  worker_ip_2      = proxmox_vm_qemu.nodes["worker2"].default_ipv4_address
}

resource "talos_machine_secrets" "secrets" {
  depends_on = [ proxmox_vm_qemu.nodes ]
}

data "talos_machine_configuration" "controlplane" {
  depends_on = [ proxmox_vm_qemu.nodes, talos_machine_secrets.secrets ]
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  docs = true
  # Ensure Talos uses correct path for ISO File
  # Disable Flannel, default CNI for Talos
  # config_patches = [
    # yamlencode({
    #   cluster = {
    #     network = {
    #       cni = {
    #         name = "none"
    #       }
    #     }
    #   }
    # }),
    # yamlencode({
    #   cluster = {
    #     proxy = {
    #       disabled = true
    #     }
    #   }
    # })
  # ]
}

data "talos_machine_configuration" "worker" {
  depends_on = [ proxmox_vm_qemu.nodes, talos_machine_secrets.secrets ]
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
  # config_patches = [
    # yamlencode({
    #   cluster = {
    #     network = {
    #       cni = {
    #         name = "none"
    #       }
    #     }
    #   }
    # }),
    # yamlencode({
    #   cluster = {
    #     proxy = {
    #       disabled = true
    #     }
    #   }
    # })
  # ]
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
  nodes = [local.controlplane_ip]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [ data.talos_machine_configuration.controlplane ]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = local.controlplane_ip
  endpoint                    = local.controlplane_ip
  apply_mode = "reboot"
  timeouts = {
    create = "7m"
    update = "5m"
  }
}

resource "talos_machine_configuration_apply" "worker1" {
  # depends_on                  = [talos_machine_bootstrap.controlplane] # Only start after controlplane is bootstrapped
  client_configuration = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_ip_1
  endpoint                    = local.worker_ip_1
  apply_mode = "reboot"
  timeouts = {
    create = "7m"
    update = "5m"
  }
}

resource "talos_machine_configuration_apply" "worker2" {
  # depends_on                  = [talos_machine_bootstrap.controlplane] # Only start after controlplane is bootstrapped
  client_configuration = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = local.worker_ip_2
  endpoint                    = local.worker_ip_2
  apply_mode = "reboot"
  timeouts = {
    create = "7m"
    update = "5m"
  }
}

resource "time_sleep" "wait_for_controlplane" {
  create_duration = "2m"
  
  depends_on = [talos_machine_configuration_apply.controlplane]
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on = [ time_sleep.wait_for_controlplane ]
  node = local.controlplane_ip
  client_configuration = talos_machine_secrets.secrets.client_configuration
  endpoint = local.controlplane_ip
  timeouts = {
    create = "5m"
  }
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.controlplane]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = local.controlplane_ip
}


# # Install Cilium CNI Helm Chart
# resource "helm_release" "cilium" {
#   dependency_update = true

#   name = "cilium"
#   namespace = "kube-cilium"
#   create_namespace = true
#   repository = "https://helm.cilium.io/"
#   chart = "cilium"
#   version = "1.20.1"

#   set = [
#     {
#       name = "kubeProxyReplacement"
#       # type = "literal"
#       value = "true"
#     },
#     {
#       name = "k8sServiceHost"
#       # type = "string"
#       value = "10.1.4.10"
#     },
#     {
#       name = "k8sServicePort"
#       value = "6443"
#       # type = "number"
#     },
#     {
#       name = "l2announcements.enabled"
#       value = "true"
#       # type = "bool"
#     },
#     {
#       name = "externalIPs.enabled"
#       value = "true"
#       # type = "bool"
#     },
#     {
#       name = "gatewayAPI.enabled"
#       value = "true"
#       # type = "bool"
#     },
#     {
#       name = "ipam.mode"
#       value = "kubernetes"
#     },
#     {
#       name = "operator.replicas"
#       value = "1"
#       # type = "string"
#     },
#     {
#       name = "securityContext.privileged"
#       value = "true"
#       # type = "bool"
#     }
#   ]
# }