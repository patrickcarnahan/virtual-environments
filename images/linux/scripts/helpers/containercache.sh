#!/bin/bash
################################################################################
##  File:  containercache.sh
##  Desc:  Prepulls Docker images used in build tasks and templates
################################################################################

# Check prereqs
echo "Checking prereqs for image pulls"
if ! command -v docker; then
    echo "Docker is not installed, cant pull images"
    exit 1
fi

# Pull images
images=(
    redis:5.0.6@sha256:c6b7e6bd9e234221509e0ebc90ad89ff491e61a604a4eb2649570e9703fafc65
    mcr.microsoft.com/dotnet/core/sdk:3.1@sha256:c3dad6b8c06d1e99f464c2dc8dbe888aacbd9f33186054cc83f64d040f6df39d
    mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim@sha256:73782314a1131580352e6de2d5e36de010a6ad17342d0d0a552f3c8cdf1b1edb
    mcr.microsoft.com/powershell:7.0.0-debian-buster-20200224-slim@sha256:728693244ac70751e8021622f472c6a7ebeab65d4e8a8ecdb45ae132b3ca54b4
    mcr.microsoft.com/mssql/server:2017-CU20-ubuntu-16.04@sha256:eb1fc9a73c9c4662d3b468b635b9be34a48724100294ac20348ac0e93c55228d
)

for image in "${images[@]}"; do
    docker pull "$image"
done

mkdir -p ~/data/docker-images

for image in $(docker image ls --format '{{ .Repository }}'); do
    docker image save $image -o "~/docker-images/${image//\//-}.tar"
done
