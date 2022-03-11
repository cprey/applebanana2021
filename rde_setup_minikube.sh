#!/bin/bash

set -eu -o pipefail

sudo yum install -y conntrack nc

docker kill $(docker ps -q)

curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
  chmod +x minikube && \
  sudo mv minikube /usr/local/bin/

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl && \
  chmod +x kubectl && sudo mv kubectl /usr/local/bin/

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
  chmod +x get_helm.sh && \
  ./get_helm.sh

minikube start