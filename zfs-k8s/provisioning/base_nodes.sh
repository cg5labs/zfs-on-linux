#!/bin/bash

#yum -y install epel-release

yum -y install epel-release
yum -y install kernel-devel
#yum -y update 
#yum -y upgrade

yum -y install https://zfsonlinux.org/epel/zfs-release-2-3.el9.noarch.rpm
yum -y install zfs
zpool create zfspv-pool /dev/vdb
zfs set compression=lz4 zfspv-pool
zfs set atime=off zfspv-pool
zfs set dedup=on zfspv-pool
zpool list
zfs get all

# Kubelet API
firewall-cmd --permanent --zone=public --add-port=10250/tcp

# NodePort range
firewall-cmd --permanent --zone=public  --add-port=30000-32767/tcp
firewall-cmd --permanent --zone=public --add-port=30000-32767/udp

# Flannel VXLAN
firewall-cmd --permanent --zone=public --add-port=8472/udp

firewall-cmd --reload
setenforce 0

# Modify the SELINUX setting to disabled
sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
