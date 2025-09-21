#!/bin/bash

#yum -y install epel-release

#yum -y install epel-release
#yum -y install kernel-devel
##yum -y update
##yum -y upgrade

#yum -y install https://zfsonlinux.org/epel/zfs-release-2-3.el9.noarch.rpm
#yum -y install zfs
#zpool create zfspv-pool /dev/vdb
#zfs set compression=lz4 zfspv-pool
#zfs set atime=off zfspv-pool
#zfs set dedup=on zfspv-pool
#zpool list
#zfs get all

# Kubelet API
#firewall-cmd --permanent --zone=public --add-port=10250/tcp

# NodePort range
#firewall-cmd --permanent --zone=public  --add-port=30000-32767/tcp
#firewall-cmd --permanent --zone=public --add-port=30000-32767/udp

# Flannel VXLAN
#firewall-cmd --permanent --zone=public --add-port=8472/udp

#firewall-cmd --reload


#cd /tmp
#cat <<EOF > flannel.xml
#<?xml version="1.0" encoding="utf-8"?>
#<service>
#  <short>flannel</short>
#  <description>flannel network fabric for containers, using VXLAN backend</description>
#  <port protocol="udp" port="8472"/>
#  <port port="8285" protocol="udp"/>
#</service>
#EOF

# https://github.com/flannel-io/flannel/issues/2055
#firewall-cmd --permanent --add-service kube-worker
#firewall-cmd --permanent --add-service etcd-client
#firewall-cmd --permanent --new-service-from-file=/tmp/flannel.xml --name=flannel
#firewall-cmd --permanent --add-service flannel
#firewall-cmd --permanent --zone=public --add-source=10.244.0.0/16
#firewall-cmd --reload


setenforce 0

# Modify the SELINUX setting to disabled
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

# sysctl tuning for Elasticsearch
cat <<EOF >> /etc/sysctl.conf
vm.max_map_count=262144
fs.file-max=65536
EOF
sysctl -p
