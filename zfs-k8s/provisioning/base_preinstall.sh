#!/bin/bash

#yum -y install epel-release
#yum -y install kernel-devel

#yum -y install https://zfsonlinux.org/epel/zfs-release-2-3.el9.noarch.rpm
#yum -y install zfs
#zpool create zfspv-pool /dev/vdb
#zfs set compression=lz4 zfspv-pool
#zfs set atime=off zfspv-pool
#zfs set dedup=on zfspv-pool
#zpool list
#zfs get all

# Kubernetes API Server
#firewall-cmd --zone=public --add-port=6443/tcp --permanent

# etcd
#firewall-cmd --zone=public --permanent --add-port=2379-2380/tcp

# Kubelet API
#firewall-cmd --permanent --zone=public --add-port=10250/tcp

# kube-scheduler
#firewall-cmd --permanent --zone=public --add-port=10259/tcp

# kube-controller-manager
#firewall-cmd --permanent --zone=public --add-port=10257/tcp

# NodePort range
#firewall-cmd --permanent --zone=public  --add-port=30000-32767/tcp
#firewall-cmd --permanent --zone=public --add-port=30000-32767/udp

# Flannel VXLAN 
#firewall-cmd --permanent --zone=public --add-port=8472/udp

#firewall-cmd --reload

cd /tmp
cat <<EOF > flannel.xml
<?xml version="1.0" encoding="utf-8"?>
<service>
  <short>flannel</short>
  <description>flannel network fabric for containers, using VXLAN backend</description>
  <port protocol="udp" port="8472"/>
  <port port="8285" protocol="udp"/>
</service>
EOF

# https://github.com/flannel-io/flannel/issues/2055
#firewall-cmd --permanent --add-service kube-control-plane
#firewall-cmd --permanent --add-service kube-control-plane-secure
#firewall-cmd --permanent --add-service kubelet
#firewall-cmd --permanent --new-service-from-file=/tmp/flannel.xml --name=flannel
#firewall-cmd --permanent --add-service flannel
#firewall-cmd --permanent --zone=public --add-source=10.244.0.0/16
#firewall-cmd --permanent --add-masquerade
#firewall-cmd --reload


#
# migrated to  Ansible playbooks (k8s-infra.yml and k8s-apps.yml)
#


# Disable SELinux
#setenforce 0
# Modify the SELINUX setting to disabled
#sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# sysctl tuning for Elasticsearch
#cat <<EOF >> /etc/sysctl.conf
#vm.max_map_count=262144
#fs.file-max=65536
#EOF
#sysctl -p

# Ansible K8s dependencies
#dnf install -y python3-pip
#pip3 install --upgrade pip
#pip3 install pyyaml
#pip3 install kubernetes
#cd /tmp
#curl -LO https://get.helm.sh/helm-v3.19.0-linux-amd64.tar.gz
#tar -zxvf helm-v3.19.0-linux-amd64.tar.gz
#mv linux-amd64/helm /usr/local/sbin/helm
#chmod +x /usr/local/sbin/helm
#helm version

# Kubecolor
#curl -LO https://github.com/kubecolor/kubecolor/releases/download/v0.5.1/kubecolor_0.5.1_linux_amd64.rpm
#dnf install -y ./kubecolor_0.5.1_linux_amd64.rpm
