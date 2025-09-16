# ZFS-on-Linux pilot for EL9 Linux Distros
Project for evaluation of ZFS features. 

Features

* VM-based deployment using Rocky Linux 9 with second disk configured as ZFS pool
* K8s-based deployment using Rocky Linux 9 K8s nodes with ZFS pool. OpenEBS CSI with localpv ZFS support.

## Tech stack

- Vagrant
- Libvirt / qemu 
- Virtualbox (todo)
  
## Setup
Ansible needs to be installed on the host for Vagrant to install dependencies during startup.

### ZFS-EL9
```text
$ cd zfs-el9
$ vagrant up
```


### ZFS-k8s
Vagrant VM startup needs to be sequential for the K8s control plane VM to intialize first and the K8s worker nodes to initialize afterwards.

```text
$ cd zfs-k8s
$ vagrant up --no-parallel
```
