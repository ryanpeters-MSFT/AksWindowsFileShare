kubectl apply -f .\namespace.yaml
kubectl apply -f .\smb-secret.yaml
kubectl apply -f .\volume.yaml
kubectl apply -f .\deployment.yaml -f .\service.yaml

# output the public IP for the service (allow time for allocation)
kubectl get svc apiservice -n apps -o jsonpath='{.status.loadBalancer.ingress[0].ip}'