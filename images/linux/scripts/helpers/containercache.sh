#!/bin/bash
################################################################################
##  File:  containercache.sh
##  Desc:  Prepulls Docker images used in build tasks and templates
################################################################################

source $HELPER_SCRIPTS/document.sh

# Check prereqs
echo "Checking prereqs for image pulls"
if ! command -v docker; then
    echo "Docker is not installed, cant pull images"
    exit 1
fi

# Information output
# systemctl status docker --no-pager

# Pull images
images=(
    redis:5.0.6@sha256:c6b7e6bd9e234221509e0ebc90ad89ff491e61a604a4eb2649570e9703fafc65
    mcr.microsoft.com/dotnet/core/sdk:3.1@sha256:c3dad6b8c06d1e99f464c2dc8dbe888aacbd9f33186054cc83f64d040f6df39d
    mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim@sha256:73782314a1131580352e6de2d5e36de010a6ad17342d0d0a552f3c8cdf1b1edb
    mcr.microsoft.com/powershell:7.0.0-debian-buster-20200224-slim@sha256:728693244ac70751e8021622f472c6a7ebeab65d4e8a8ecdb45ae132b3ca54b4
    mcr.microsoft.com/mssql/server:2017-CU20-ubuntu-16.04@sha256:eb1fc9a73c9c4662d3b468b635b9be34a48724100294ac20348ac0e93c55228d
    mcr.microsoft.com/mssql/server:2019-CU3-ubuntu-18.04@sha256:e064843673f08f22192c044ffa6a594b0670a3eb3f9ff7568dd7a65a698fc4d6
    mcr.microsoft.com/mssql/server:2019-CU4-ubuntu-18.04@sha256:360f6e6da94fa0c5ec9cbe6e391f411b8d6e26826fe57a39a70a2e9f745afd82
)

for image in "${images[@]}"; do
    docker pull "$image"
done

## Add container information to the metadata file
 DocumentInstalledItem "Cached container images"

while read -r line; do
    DocumentInstalledItemIndent "$line"
done <<< "$(docker images --digests --format '{{.Repository}}:{{.Tag}} (Digest: {{.Digest}})')"
