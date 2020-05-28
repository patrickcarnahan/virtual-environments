#!/bin/bash

echo "$(date +%T) Configuring docker daemon to use local SSD" | tee -a ~/actions-warmup.log
sudo systemctl stop docker
echo "{}" | jq '. += { "data-root": "/mnt/docker" }' | sudo tee /etc/docker/daemon.json
sudo systemctl start docker

# Pull images
images=(
    redis:5.0.6@sha256:c6b7e6bd9e234221509e0ebc90ad89ff491e61a604a4eb2649570e9703fafc65
    mcr.microsoft.com/dotnet/core/sdk:3.1@sha256:c3dad6b8c06d1e99f464c2dc8dbe888aacbd9f33186054cc83f64d040f6df39d
    mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim@sha256:73782314a1131580352e6de2d5e36de010a6ad17342d0d0a552f3c8cdf1b1edb
    mcr.microsoft.com/powershell:7.0.0-debian-buster-20200224-slim@sha256:728693244ac70751e8021622f472c6a7ebeab65d4e8a8ecdb45ae132b3ca54b4
    mcr.microsoft.com/mssql/server:2017-CU20-ubuntu-16.04@sha256:eb1fc9a73c9c4662d3b468b635b9be34a48724100294ac20348ac0e93c55228d
)

echo "[$(date +%T)] Pulling docker images" | tee -a ~/actions-warmup.log

for image in "${images[@]}"; do
    echo "[$(date +%T)] Pulling image $image" | tee -a ~/actions-warmup.log
    docker pull "$image" >> ~/actions-warmup.log
    echo "[$(date +%T)] Finished pulling image $image" | tee -a ~/actions-warmup.log
done

# make sure the minikube home exists
sudo mkdir -p /mnt/minikube
sudo chown AzDevOps /mnt/minikube

sudo apt-get install -y --no-install-recommends curl

echo "[$(date +%T)] Finished pulling docker images" >> ~/actions-warmup.log
pwsh -File ~/actions-warmup.ps1 2>&1 | tee -a ~/actions-warmup.log
