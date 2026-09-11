locals {
  controlplane_ip = proxmox_vm_qemu.nodes["controlplane"].default_ipv4_address
  cluster_endpoint = "https://${local.controlplane_ip}:6443"
  worker_ip_1 = proxmox_vm_qemu.nodes["worker1"].default_ipv4_address
  worker_ip_2 = proxmox_vm_qemu.nodes["worker2"].default_ipv4_address
}

resource "talos_machine_secrets" "secrets" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.secrets.machine_secrets
}

data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.secrets.client_configuration
#   nodes = [local.controlplane_ip,local.worker_ip_1,local.worker_ip_2]
  nodes = [local.controlplane_ip]
}

###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
#
#
# CONTROL PLANE NODE STILL LOSING IP AFTER CONFIG APPLY. SOMETHING WITH QEMU?
#
#
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################
###########################################################################################

resource "talos_machine_configuration_apply" "controlplane" {
  client_configuration  = talos_machine_secrets.secrets.client_configuration
#   client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                  = local.controlplane_ip
  endpoint              = local.controlplane_ip
}

resource "talos_machine_configuration_apply" "worker1" {
  depends_on = [ talos_machine_configuration_apply.controlplane ]
  client_configuration  = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                  = local.worker_ip_1
  endpoint              = local.worker_ip_1
}

resource "talos_machine_configuration_apply" "worker2" {
  depends_on = [ talos_machine_configuration_apply.controlplane ]
  client_configuration  = talos_machine_secrets.secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                  = local.worker_ip_2
  endpoint              = local.worker_ip_2
}

resource "talos_machine_bootstrap" "controlplane" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]
  node                 = local.controlplane_ip
  endpoint = local.controlplane_ip
  client_configuration = talos_machine_secrets.secrets.client_configuration
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [talos_machine_bootstrap.controlplane]
  client_configuration = talos_machine_secrets.secrets.client_configuration
  node                 = local.controlplane_ip
}