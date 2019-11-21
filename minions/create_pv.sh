#!/bin/bash

DIRNAME=/home/kube/app/

for c in $(cat /etc/hosts | grep worker | awk {'print $2'})
do
echo $c
    sshpass -e ssh -o StrictHostKeyChecking=no root@$c -p 21   "mkdir -p $DIRNAME; \
								mkdir -p $DIRNAME/hd; \
								mkdir -p $DIRNAME/tv; \
								chmod 777 -R $DIRNAME"
done

