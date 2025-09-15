#!/bin/bash

#-------------------------------------------------------------
# Vagrantfile runs this script to install Ansible roles
#-------------------------------------------------------------

# create base path
if [[ ! -d provisioning/roles ]]; then
  mkdir -p provisioning/roles
fi

# check and install/update Ansible roles
if [[ ! -f provisioning/requriements.yml ]]; then
  ansible-galaxy install -r provisioning/requirements.yml -p provisioning/roles
fi
