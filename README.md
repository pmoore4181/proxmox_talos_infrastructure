# Cluster Setup
## About
- Create 3 VMs in Proxmox
- Generate Talos Configs and apply to VMS
    - 1 Controlplane
    - 2 Workers

## Prereqs
- Proxmox VE
- Data storage loaded into proxmox VE
    - currently using thumbdrive. upgrade to ssd would be good

## Commands
### Set envars
    - `source ./envars_in_terminal.sh`
### Proxmox Infra
    - `tf apply -var-file proxmox.tfvars`

## Instructions
- Followed steps here:
    - https://docs.siderolabs.com/talos/v1.9/platform-specific-installations/virtualized-platforms/proxmox

## Envars
- **Created shell script to add envars as tmux envars so they are applied to all panes in session**
- envars_in_terminal.sh

## Adding Storage
- USB Stick plugged into Lenovo Thinkpad laptop
- mounted volume 
    - `sudo mkdir /mnt/proxmox`
    - `lsblk`
    - `sudo mount /dev/sda1 /mnt/proxmox`
- added mounted volume as storage in Proxmox UI
    - Datacenter
        - Storage
            - Add -> Directory
                - ID: datastick_sport
                - Directory: /mnt/proxmox
                - Content: Backup, Container
- update terraform code to use new Directory

# Terraform Setup
## Proxmox
- Provider: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
        - `pveum role modify TerraformProv -privs "Datastore.AllocateSpace Datastore.AllocateTemplate Datastore.Audit Pool.Allocate Sys.Audit Sys.Console Sys.Modify VM.Allocate VM.Audit VM.Clone VM.Config.CDROM VM.Config.Cloudinit VM.Config.CPU VM.Config.Disk VM.Config.HWType VM.Config.Memory VM.Config.Network VM.Config.Options VM.Migrate VM.PowerMgmt SDN.Use VM.GuestAgent.Audit Pool.Audit"`
        - `pveum user add terraform-prov@pve --password <password>`
        - `pveum aclmod / -user terraform-prov@pve -role TerraformProv`

- Create Connection to Proxmox VE via API TOKEN
    - add Environment Variables to host machine
        - `export PM_API_TOKEN_ID=terraform-prov@pve!tf_infra`
        - `export PM_API_TOKEN_SECRET=<secret>`

- Create `controlplane`, `worker`, and `worker1` VMs
- Apply Talos configs via Terraform
- Output kubeconfig and talosconfig
- Talos Config
    - `$ terraform output -raw talosconfig > .../terraform/.talos/talosconfig.yaml`
    - `$ export TALOSCONFIG=.../terraform/.talos/talosconfig.yaml`
- Kubeconfig
    - `$ terraform output -raw kubeconfig > .../terraform/.kube/kubeconfig.yaml`
    - `$ export KUBECONFIG-.../terraform/.kube/kubeconfig.yaml`


# Outputs
- `./terraform/outputs.tf`