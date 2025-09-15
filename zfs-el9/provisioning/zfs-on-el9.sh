#!/bin/bash

#-------------------------------------------------------------
# ZFS on Linux install script for EL 9 distos
# Tested on Rocky 9
# Script has been  refactored as Ansible playbook
#-------------------------------------------------------------

#yum -y install epel-release
#yum -y install kernel-devel

#yum -y install https://zfsonlinux.org/epel/zfs-release-2-3.el9.noarch.rpm
#yum -y install zfs
#echo zfs | tee /etc/modules-load.d/zfs.conf
#zpool create zfspv-pool /dev/vdb
#zfs set compression=lz4 zfspv-pool
#zfs set atime=off zfspv-pool
#zfs set dedup=on zfspv-pool
#zpool list
#zfs get all

