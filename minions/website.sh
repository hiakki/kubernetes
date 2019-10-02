#!/bin/bash
cd /home/madmin/
#tar czf website.tar.gz tricksvibe
#sshpass -e sftp -oBatchMode=no -b -  -P 21 root@minion1 <<< $'put website.tar.gz\n bye'
#sshpass -e ssh root@minion1 -p 21 'bash -s' < minions/git_pull.sh

for c in $(cat /etc/hosts | grep minion | awk {'print $2'})
do
echo $c
    sshpass -e ssh -o StrictHostKeyChecking=no root@$c -p 21 'bash -s' < minions/git_pull.sh
done
