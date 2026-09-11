output "vm_details" {
  description = "VM names and their IP addresses"
  value = {
    for name, vm in proxmox_vm_qemu.nodes :
    name => {
      ip   = vm.default_ipv4_address
      vmid = vm.vmid
    }
  }
}
output "proxmox_endpoint" {
  description = "PROXMOX IP Endpoint"
  value       = var.pm_api_url
}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = resource.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}