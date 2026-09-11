resource "proxmox_vm_qemu" "nodes" {
  for_each = { for config in var.vm_configs : config.vm_name => config }

  name        = each.value.vm_name
  target_node = var.node_name
  description = each.value.vm_description
  agent       = 1 # Enables QEMU Guest Agent
  qemu_os     = "l26"
  tags        = each.value.vm_tags
  skip_ipv6   = true
  memory      = each.value.memory
  scsihw      = "virtio-scsi-single"

  cpu {
    cores   = each.value.cpu_cores
    sockets = 1
  }

  disk {
    iso  = var.talos_iso_file_location
    type = "cdrom"
    slot = "ide2"
  }

  disk {
    slot     = "scsi0"
    storage  = var.storage_location
    size     = each.value.bootdisk_size
    iothread = true
    format   = "raw"
  }

  pxe = false
  network {
    id        = 1
    bridge    = "vmbr0"
    firewall  = false
    link_down = false
    model     = "virtio"
  }
}