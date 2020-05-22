#!/bin/bash
################################################################################
##  File:  setup-k8s-cluster.sh
##  Desc:  Sets up the actions-dev minikube cluster
################################################################################

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

kubeVersion='v1.16.9'
minikube start -p actions-dev --download-only --kubernetes-version=$kubeVersion --vm-driver 'docker'
