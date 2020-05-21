# Kubernetes Dashboard
###### Ref - https://github.com/kubernetes/dashboard

Just deploy this file, using following command

kubectl create -f https://raw.githubusercontent.com/hiakki/kubernetes/master/kubernetes_dashboard/changed.yaml

No need to use "kubectl proxy"

## To access dashboard, just use the following URI

https://Public_IPv4

###### Ref - https://www.replex.io/blog/how-to-install-access-and-add-heapster-metrics-to-the-kubernetes-dashboard

After this make sure to create a service account and secret

> kubectl create serviceaccount <username>

> kubectl create clusterrolebinding (username) --clusterrole=cluster-admin --serviceaccount=default:(username)

> kubectl get secrets

> kubectl describe secret (secret-name-you-got-from-previous-step)

## Dashboard will ask for token or config file, choose token on it and enter the token, you received from above step
