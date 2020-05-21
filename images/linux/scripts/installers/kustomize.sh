#!/bin/bash
################################################################################
##  File:  kustomize.sh
##  Desc:  Installs kustomize
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

version=3.4.0

if ! command -v 'kustomize'; then
    curl -Lo kustomize.tar.gz https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2Fv3.4.0/kustomize_v${version}_linux_amd64.tar.gz
    tar -xzf "kustomize.tar.gz"
    chmod +x kustomize
    mv kustomize /usr/local/bin/
fi

if ! command -v kustomize; then
    echo "kustomize was not installed"
    exit 1
fi

# Document what was added to the image
echo "Documenting $version..."
DocumentInstalledItem "kustomize $version"
