```kubectl
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
kubectl create namespace curl
kubectl label namespace curl ns=nginx
```