#!/bin/bash

cd /home/kube/kubernetes/php-app
ext_ip=10.7.3.68

case $1 in
tv)
my=tv
ext_port_nginx=80
node_port_nginx=30420
ext_port_php=9000
node_port_php=30421
website_name=www.tricskvibe.tk
;;
hd)
my=hd
ext_port_nginx=81
node_port_nginx=31420
ext_port_php=9001
node_port_php=31421
website_name=www.hdhxmovies.ga
;;
vr)
my=vr
ext_port_nginx=82
node_port_nginx=32420
ext_port_php=9002
node_port_php=32421
website_name=www.tyohaar.tk
;;
*)
echo 'Usage launch.sh <tv/hd/vr>'
exit
;;
esac


kubectl delete -f "$my/$my-nginx/"
kubectl delete -f "$my/$my-php/"
rm -rf $my

sleep 5

mkdir -p $my
cd $my
cp ../php "$my-php" -r
cp ../nginx "$my-nginx" -r

configmap="$my-nginx/nginx_configMap.yaml"
nginx_deployment="$my-nginx/nginx_deployment.yaml"
nginx_service="$my-nginx/nginx_service.yaml"
nginx_hpa="$my-nginx/nginx_hpa.yaml"

php_ini="$my-php/php_ini.yaml"
php_www="$my-php/php_www.conf.yaml"
php_deployment="$my-php/php_deployment.yaml"
php_service="$my-php/php_service.yaml"
php_hpa="$my-php/php_hpa.yaml"

sed -i "s/my/$my/g" $php_ini
sed -i "s/my/$my/g" $php_www
sed -i "s/my/$my/g" $php_deployment
sed -i "s/my/$my/g" $php_service
sed -i "s/ext_ip/$ext_ip/g" $php_service
sed -i "s/ext_port_php/$ext_port_php/g" $php_service
sed -i "s/node_port_php/$node_port_php/g" $php_service
sed -i "s/my/$my/g" $php_hpa

kubectl apply -f "$my-php/"

sed -i "s/my/$my/g" $configmap
sed -i "s/ext_ip:ext_port_php/$ext_ip:$ext_port_php/g" $configmap
sed -i "s/website_name/$website_name/g" $configmap
sed -i "s/my/$my/g" $nginx_deployment
sed -i "s/my/$my/g" $nginx_service
sed -i "s/ext_ip/$ext_ip/g" $nginx_service
sed -i "s/ext_port_nginx/$ext_port_nginx/g" $nginx_service
sed -i "s/node_port_nginx/$node_port_nginx/g" $nginx_service
sed -i "s/my/$my/g" $nginx_hpa

kubectl apply -f "$my-nginx/"

kubectl get configmap,deploy,svc,hpa,pods -o wide
