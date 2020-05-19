#!/bin/bash
################################################################################
##  File:  kustomize.sh
##  Desc:  Installs kustomize
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

mkdir -p /agent/_work/1/s
git clone https://$SYSTEM_ACCESSTOKEN@dev.azure.com/mseng/AzureDevOps/_git/AzDevNext ./agent/_work/1/s

pushd /agent/_work/1/s
version=$(git rev-parse HEAD)
pwsh -c "& { init.ps1; dotnet restore; scorch -y }"
popd

# Document what was added to the image
echo "Documenting $version..."
DocumentInstalledItem "mseng/azdevnext ($version)"
