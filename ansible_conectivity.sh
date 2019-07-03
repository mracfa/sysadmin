#!/usr/bin/sh



if [ ${#@} == 0 ]; then
    echo "This script checks conectivity from Ansible to host:22"
    echo "Usage: $0 /home/$USER/workspace/msem-ansible/inventories/EXAMPLE/hosts [path]"
    echo "* param1: path of the inventory hosts file"
    exit 0
fi

ARG=$1

for i in `cat $ARG |grep -v "\[" |grep -v ^#`; do nc -w 1 -z -v $i 22; done
