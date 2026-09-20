variable "pm_api_url" {
  type        = string
  description = "API endpoint for Proxmox VE"
}
variable "vm_configs" {
  type = list(object({
    vm_name        = string
    vm_description = string
    vm_tags        = string
    cpu_cores      = number
    memory         = number
    bootdisk_size  = number
  }))
  description = "Configs for ControlPlane and Worker Node VMs"
}
variable "node_name" {
  type        = string
  description = "The name of the Proxmox Cluster Node (node2)"
}
variable "talos_iso_file_location" {
  type        = string
  description = "Proxmox Location of Talos ISO file. ex 'local:iso/talos-qemuEnabled-amd64.iso'"
}
variable "storage_location" {
  type        = string
  description = "Storage mount for Control Plane and Workers. ex 'datastick_sport'"
}
variable "cluster_name" {
  type        = string
  description = "Talos Cluster Name"
}
variable "talos_installer_image" {
  type        = string
  description = "Installer image from sidero labs docs"
}