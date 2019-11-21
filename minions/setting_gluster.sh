#!/bin/bash

DIRNAME=/home/kube/app/

for c in $(cat /etc/hosts | grep worker | awk {'print $2'})
do
echo $c
    sshpass -e ssh -o StrictHostKeyChecking=no root@$c -p 21   "\
		apt install glusterfs-client -y; \
		mkdir -p $DIRNAME; \
		mount -t glusterfs master:/gvol0 $DIRNAME;"
done

