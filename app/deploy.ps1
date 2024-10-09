# build the app with docker
az acr login -n binarydad
docker build -f .\Dockerfile . -t binarydad.azurecr.io/apiservice:latest
docker push binarydad.azurecr.io/apiservice:latest