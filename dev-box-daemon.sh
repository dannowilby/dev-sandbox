#!/bin/bash

echo "Preparing your kind cluster..."

docker build -t sandbox-runtime . && kind load docker-image sandbox-runtime:latest --name agent-sandbox
kubectl apply -f ./manifest/template.yaml
kubectl apply -f ./manifest/sandbox.yaml
kubectl apply -f ./manifest/deploy

echo "Done!"