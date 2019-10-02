for c in $(cat /etc/hosts | grep minion | awk {'print $2'})
do
echo $c
    sshpass -e ssh -o StrictHostKeyChecking=no root@$c -p 21 'bash -s' < master/performance_monitor.sh
done
