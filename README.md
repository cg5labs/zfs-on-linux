# ZFS-on-Linux pilot for EL9 Linux Distros
Project for evaluation of ZFS features. 

Features

* VM-based deployment using Enterprise Linux 9 distros with second disk configured as ZFS pool
* K8s-based deployment using Rocky Linux 9 K8s nodes with ZFS pool. OpenEBS CSI with localpv ZFS support.

## Test Matrix

| Distro name     | Status   | Notes                                        |
|:--------------- |:---------|:---------------------------------------------|
| Rocky Linux 9   | OK       |                                              |
| Alma Linux 9    | OK       | Upgrade Vagrant box kernel to latest to run  |
| RHEL 9          | untested | RHEL9 box missing public RPM repos           |
| CentOS 9 Stream | OK       |                                              |
| Oracle Linux 9  | OK       |                                              |

## Tech stack

- Vagrant
- Libvirt / qemu 
- Virtualbox (WIP)
  
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

The Vagrant VMs for the K8s cluster default settings have this sizing and require sufficient resources on the host:

| VM     | CPU [#] | RAM [gb]  | Disk [gb] | Description    |
|:-------|:--------|:----------|-----------|----------------|
| k8s-cp | 4       | 8         | 10        | Control Plane  |
| k8s-w1 | 4       | 8         | 250       | Worker Node    |
| k8s-w2 | 4       | 8         | 250       | Worker Node    |
| k8s-w3 | 4       | 8         | 250       | Worker Node    |


