#!/bin/bash


# load user configuration
source userconfig/configuration.sh
sudo echo "[duts]" > /etc/ansible/hosts
sudo nmap --exclude $EXCLUDE --open -sn ${SUBNET} -oG - | awk '/Up$/{print $2}' | sort >> /etc/ansible/hosts
ansible duts -a "apt update " -u root
ansible duts -a "apt -y -qq upgrade " -u root
ansible duts -a "reboot " -u root
