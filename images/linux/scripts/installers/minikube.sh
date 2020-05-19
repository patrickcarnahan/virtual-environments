#!/bin/bash
################################################################################
##  File:  minikube.sh
##  Desc:  Installs minikube
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/document.sh

version=1.7.2

curl -Lo minikube https://storage.googleapis.com/minikube/releases/v${version}/minikube-linux-amd64
chmod +x minikube
mv minikube /usr/local/bin/

# Document what was added to the image
echo "Documenting $version..."
DocumentInstalledItem "minikube $version"
