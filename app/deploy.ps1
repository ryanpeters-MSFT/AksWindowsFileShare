$ACR = "binarydad"
$TAG = "$($ACR).azurecr.io/apiservice:latest"

# log into ACR
az acr login -n $ACR

# build and push image to registry
docker build -f .\Dockerfile . -t $TAG
docker push $TAG