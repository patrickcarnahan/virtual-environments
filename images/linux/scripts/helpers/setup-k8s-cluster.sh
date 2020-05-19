#!/bin/bash
################################################################################
##  File:  setup-k8s-cluster.sh
##  Desc:  Sets up the actions-dev minikube cluster
################################################################################

totalCpus=$(nproc --all)
totalMem=$(free -b | awk '/^Mem/ {printf $2 }')
kubeCpus=$(($totalCpus / 2))
kubeMem="$(($totalMem / 1024 / 1024 / 1024 / 2)) GB"
kubeDisk='30gb'
kubeVersion='v1.16.9'

echo "Starting a minikube cluster with memory=$kubeMem, cpus=$kubeCpus, disk=$kubeDisk, kubernetes=$kubeVersion"
minikube start -p actions-dev \
    --vm-driver=docker \
    --disk-size="$kubeDisk" \
    --cpus="$kubeCpus" \
    --memory="$kubeMem" \
    --kubernetes-version="$kubeVersion" \
    --feature-gates="StartupProbe=true" \
    --extra-config="apiserver.service-node-port-range=1-65535"
