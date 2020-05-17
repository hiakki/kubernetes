# Kubernetes Dashboard
# Ref - https://github.com/kubernetes/dashboard

Just deploy this file, using following command

kubectl create -f https://raw.githubusercontent.com/hiakki/kubernetes/master/kubernetes_dashboard/changed.yaml

No need to use "kubectl proxy"

# To access dashboard, just use the following URI

https://Publi IPv4

# Ref - https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard

After this make sure to create a service account and secret

kubectl create serviceaccount dashboard-admin-sa

kubectl create clusterrolebinding dashboard-admin-sa --clusterrole=cluster-admin --serviceaccount=default:dashboard-admin-sa

kubectl get secrets

kubectl describe secret dashboard-admin-sa-token-abcde

# Dashboard will ask for token or config file, choose token on it and enter the token, you received from above step
