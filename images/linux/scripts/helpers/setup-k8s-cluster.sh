#!/bin/bash
################################################################################
##  File:  setup-k8s-cluster.sh
##  Desc:  Sets up the actions-dev minikube cluster
################################################################################

BASE_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

rm -f "$BASE_PATH/deploycore.ps1"

cat << EOF > "$BASE_PATH/deploycore.ps1"
Set-Location /agent/_work/1/s
./init.ps1

Import-Module ./Scripts/lib/DeploymentUtilities.psm1
Start-Cluster -Driver 'docker' -UseAllResources \$true
Deploy-SingletonService -Service 'mssql' -Environment 'test'
Deploy-SingletonService -Service 'redis' -Environment 'test'

kubectl rollout status -w deployment.apps/mssql --timeout=10m
if (!\$?) {
    throw "Failed to wait for mssql deployment to finish"
}

kubectl rollout status -w deployment.apps/redis --timeout=10m
if (!\$?) {
    throw "Failed to wait for redis deployment to finish"
}
EOF


pwsh -File "$BASE_PATH/deploycore.ps1"

