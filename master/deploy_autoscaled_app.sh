#!/bin/bash
kubectl create -f /home/madmin/yamls/nginx_php-fpm_multicontainer_deployment.yaml
kubectl autoscale deployment tv --cpu-percent=50 --min=5 --max=8
