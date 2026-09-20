# Cluster Setup
## About
- Create 3 VMs in Proxmox
- Generate Talos Configs and apply to VMS
    - 1 Controlplane
    - 2 Workers
- Create Kubernetes cluster
- **CNI NOT INSTALLED. MUST INSTALL CILIUM OR OTHER CNI**

## Prereqs
- Proxmox VE
- Data storage loaded into proxmox VE
    - currently using thumbdrive. upgrade to ssd would be good

## Commands
### Set envars
`source ./envars_in_terminal.sh`
### Proxmox Infra
`tf apply -var-file proxmox.tfvars`

## Instructions
- Followed steps here:
    - https://docs.siderolabs.com/talos/v1.9/platform-specific-installations/virtualized-platforms/proxmox

## Envars
```
KUBECONFIG = file location
TALOSCONFIG = file location
CONTROL_PLANE_IP
WORKER_IP_1
WORKER_IP_2
PM_API_TOKEN_ID = Proxmox Identity used for TF deployment
PM_API_TOKEN_SECRET
```

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

## Talos
- Create `controlplane`, `worker1`, and `worker2` VMs
- Apply Talos configs via Terraform
- Output kubeconfig and talosconfig
- Talos Config
    - `$ terraform output -raw talosconfig > .../terraform/.talos/talosconfig.yaml`
    - `$ export TALOSCONFIG=.../terraform/.talos/talosconfig.yaml`
- Kubeconfig
    - `$ terraform output -raw kubeconfig > .../terraform/.kube/kubeconfig.yaml`
    - `$ export KUBECONFIG-.../terraform/.kube/kubeconfig.yaml`

## Container Network Interface (CNI)
- Uninstall Flannel (default CNI for Talos) in `talos.tf`
- Install Cilium via Terraform and Helm in Helm chart

# Outputs
- `./terraform/outputs.tf`

# Steps after completion
1. Update `envars_in_terminal.sh`
    - IP Addresses
    - Environment variables
2. Export TF Output `kubeconfig` and `talosconfig`
    - make sure file path matches envars
3. Verify VMs are ON. Sometimes they don't reboot all the way
4. Install Cilium (Flannel is removed in talos vm TF configs)
    - `helm repo add cilium https://helm.cilium.io/`
    - `helm repo update`
    - `helm install cilium cilium/cilium --namespace kube-system --version 1.19.2 --values .../helm/cilium-values.yaml`






















# Left off
- ran tf apply
- flannel removed
- need to install fluxcd and integrate github repo
- use fluxcd to install cilium, longhorn, etc.