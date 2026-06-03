# AGENTS.md - ZFS-on-Linux Codebase Guide

## Project Overview

This is a infrastructure-as-code project that deploys **ZFS (Zettabyte File System) storage** on Enterprise Linux 9 distributions. It provides two distinct deployment scenarios:

- **zfs-el9/**: Single-VM ZFS deployment for quick evaluation
- **zfs-k8s/**: Kubernetes cluster with OpenEBS-managed ZFS storage backend

Both use **Vagrant + Ansible** to fully automate deployment and configuration.

## Architecture & Data Flows

### Component Architecture

```
Vagrant (VM orchestration)
  ├── libvirt/qemu (Linux provider - default)
  ├── VirtualBox (fallback provider)
  └── Provisioners:
      ├── Shell scripts (base setup)
      └── Ansible playbooks (configuration)
           └── Roles (geerlingguy.*, cg5labs.*)
```

### Deployment Data Flow

```
zfs-el9/ flow:
1. Vagrant reads Vagrantfile → Sets up single VM with 2 disks
2. ansible_roles_setup.sh → Downloads roles via ansible-galaxy
3. zfs-on-linux.yml → Installs ZFS, creates pool on disk2

zfs-k8s/ flow:
1. Vagrant sequentially (--no-parallel) spins up VMs:
   - k8s-cp (control plane) with 10GB ZFS disk
   - k8s-w1, k8s-w2, k8s-w3 (workers) with 250GB ZFS disks each
2. Shell pre-install scripts prepare base environment
3. k8s-cluster.yml → Installs Kubernetes + Containerd
4. k8s-infra.yml → Deploys infrastructure (monitoring, storage)
5. k8s-apps.yml → Deploys workload applications
```

**Critical**: K8s deployment **must be sequential** (see `--no-parallel` flag). Control plane initializes first; workers join after control plane is ready.

### Storage Backend Design

- **Default ZFS pool name**: `zfspv-pool` (matches OpenEBS PV naming convention)
- **ZFS attributes configured**:
  - `compression=on` - Reduces storage overhead
  - `atime=off` - Improves performance
  - `dedup=on` - Enables deduplication for K8s use case
- **K8s integration**: OpenEBS CSI driver provides PVC support backed by ZFS volumes

## Project-Specific Patterns & Conventions

### Vagrant Configuration Patterns

**Provider Detection** (both Vagrantfiles):
```ruby
if RUBY_PLATFORM.downcase.include?("linux")
    ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'
end
```
- Linux → libvirt/qemu (primary)
- Other OS → VirtualBox (secondary)

**Disk Device Mapping** (provider-dependent):
- libvirt/qemu: `/dev/vdb` (virtio)
- VirtualBox: `/dev/sdb` (SATA)

This is passed to Ansible via `extra_vars: { disk2_device: ... }` (see Vagrantfiles line 146, 149).

### Ansible Role Usage Patterns

**Role installation**: Automatically triggered by `ansible_roles_setup.sh` at `vagrant up` time:
```sh
ansible-galaxy install -r provisioning/requirements.yml -p provisioning/roles
```
Downloads external roles (geerlingguy.ntp, containerd, kubernetes) into local `provisioning/roles` directory.

**Custom roles** (in `provisioning/roles/`):
- `cg5labs.zfs`: ZFS installation and pool setup (duplicated logic - see `zfs-on-linux.yml` vs. `cg5labs.zfs/tasks/main.yml`)
- `cg5labs.firewalld`: Firewall rules for K8s services

**Role application**:
- Control plane only gets: firewalld, ntp, containerd, kubernetes
- Worker nodes get: zfs, firewalld, ntp, containerd, kubernetes (note: control plane skips ZFS role)

### Inventory Management

Different inventory files per provider:
- `zfs-el9/provisioning/inventory_qemu` → libvirt deployments
- `zfs-el9/provisioning/inventory_vbox` → VirtualBox deployments
- `zfs-k8s/provisioning/inventory.yml` → K8s cluster (single inventory, multiple hosts)

K8s inventory defines host groups:
```yaml
k8s_cp:      # Control plane
k8s_nodes:   # Worker nodes (k8s-w1, w2, w3)
```

## Critical Developer Workflows

### Deploy zfs-el9 (Quick Start)
```bash
cd zfs-el9
vagrant up                          # Creates VM, provisions ZFS
vagrant ssh                         # Access VM
zpool list                          # Verify pool created
zfs get all                         # Inspect ZFS attributes
vagrant destroy -f                  # Cleanup
```

### Deploy zfs-k8s (K8s Cluster)
```bash
cd zfs-k8s
vagrant up --no-parallel           # MUST use --no-parallel!
vagrant ssh -c "kubectl get nodes" # Verify cluster from control plane
vagrant destroy -f                  # Cleanup all VMs
```

### Common Troubleshooting Commands

```bash
# Ansible debuging
cd zfs-k8s
ansible-inventory -i provisioning/inventory.yml --list  # Verify hosts

# Vagrant machine inspection
vagrant status                      # Show VM states
vagrant global-status               # Show all vagrant VMs on system

# Inside VM (after vagrant ssh)
journalctl -u kubelet -f            # Kubernetes logs
systemctl status zfs                # ZFS service status
zpool status                        # ZFS pool health
```

### Idempotency Gotchas

**ZFS pool creation is not idempotent**:
```yaml
- name: Create ZFS pool
  command: zpool create -f zfspv-pool {{ disk2_device }}
  args:
    creates: /zfspv-pool            # Prevents re-running if pool exists
```

The `creates:` guard prevents repeated pool creation, but disk2 must be clean for initial provisioning.

## External Dependencies & Integration Points

### Ansible Galaxy Roles

Installed via `requirements.yml` and used as external dependencies:

| Role | Purpose | Version | Notes |
|------|---------|---------|-------|
| `geerlingguy.ntp` | Time synchronization | Latest | Required before K8s (clock skew breaks cluster) |
| `geerlingguy.containerd` | Container runtime | Latest | Kubernetes prerequisite |
| `geerlingguy.kubernetes` | K8s cluster bootstrap | Latest | Handles kubeadm, kubelet, kube-proxy |

These roles have their own defaults; check `provisioning/roles/{role}/defaults/main.yml` for configuration.

### External URLs (Hard-coded in playbooks)

- ZFS GPG key: https://raw.githubusercontent.com/zfsonlinux/zfsonlinux.github.com/master/zfs-release/RPM-GPG-KEY-openzfs-key2
- ZFS release RPM: https://zfsonlinux.org/epel/zfs-release-2-3.el{VERSION}.noarch.rpm
- ZFS package repo: http://download.zfsonlinux.org/epel/{VERSION}/{ARCH}/...
- Kube-flannel manifest: Embedded in `provisioning/files/kube-flannel.yml` (copied to VM at runtime)

**Network requirements**: Both libvirt and VirtualBox require defined network names:
- libvirt: uses `libvirt_network_name: "internal"` for K8s cluster communication
- VirtualBox: uses standard host-only adapters

## Key Files for Understanding Patterns

1. **Vagrantfiles** (`zfs-el9/Vagrantfile`, `zfs-k8s/Vagrantfile`)
   - VM configuration, storage setup, provider-specific logic
   - Lines 140-152 show Ansible provisioner configuration with inventory/extra_vars selection

2. **Playbooks** (`zfs-on-linux.yml`, `k8s-cluster.yml`, `k8s-infra.yml`, `k8s-apps.yml`)
   - Task orchestration; shows order of operations
   - `k8s-cluster.yml` line 3-4: Control plane before workers

3. **Custom roles** (`cg5labs.zfs`, `cg5labs.firewalld`)
   - ZFS installation specifics for EL9
   - Firewall port configuration for K8s services

4. **Inventory files** (`provisioning/inventory.yml`)
   - Host group definitions; IP/hostname mappings
   - Variable assignments per-host (kubernetes_role, ntp_timezone)

## When Adding Features

- **New ZFS settings**: Modify `zfs set` commands in `cg5labs.zfs/tasks/main.yml` AND `zfs-on-linux.yml` (duplicate logic)
- **K8s networking changes**: Update Vagrantfile network definitions AND `provisioning/inventory.yml` IPs in sync
- **New Ansible roles**: Add to `requirements.yml` → Downloaded automatically; add to appropriate playbooks
- **Provider support**: Test with both libvirt (`inventory_qemu`) and VirtualBox (`inventory_vbox`) device mappings

