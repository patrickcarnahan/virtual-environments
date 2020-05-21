#!/bin/bash
################################################################################
##  File:  kubernetes-tools.sh
##  Desc:  Installs kubectl, helm
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

## Install kubectl
if ! command -v 'kubectl'; then
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    touch /etc/apt/sources.list.d/kubernetes.list

    # Based on https://kubernetes.io/docs/tasks/tools/install-kubectl/, package is xenial for both OS versions.
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubectl
fi

# Run tests to determine that the software installed as expected
echo "Testing to make sure that script performed as expected, and basic scenarios work"
if ! command -v kubectl; then
    echo "kubectl was not installed"
    exit 1
fi

# Document what was added to the image
echo "Lastly, documenting what we added to the metadata file"
DocumentInstalledItem "kubectl ($(kubectl version --client --short |& head -n 1))"
