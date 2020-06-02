Ref - https://devopscube.com/setup-grafana-kubernetes/

https://linuxacademy.com/blog/kubernetes/running-prometheus-on-kubernetes/

Files and Folders -

k8s-dashboard
|
|--- prometheus
|    |
|    |--- config.yaml
|    |--- clusterRole.yaml
|    |--- deployment.yaml
|    |--- service.yaml
|        
|--- grafana
     |
     |--- config.yaml
     |--- deployment.yaml
     |--- service.yaml

1. Create a namespace "monitoring"

kubectl create namespace monitoring

2. Deploy prometheus 1st

kubectl apply -f k8s-dashboard/prometheus/

3. Deploy Grafana now

kubectl apply -f k8s-dashboard/grafana/
