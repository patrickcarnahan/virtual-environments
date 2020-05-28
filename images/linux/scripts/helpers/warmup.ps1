$sw = [System.Diagnostics.Stopwatch]::StartNew()
Write-Output "$(date +%T) Starting actions warmup"

Set-Location /agent/_work/1/s
./init.ps1
Import-Module ./Scripts/lib/DeploymentUtilities.psm1

Write-Output "$(date +%T) Starting minikube cluster actions-dev"
Start-Cluster -Driver 'docker' -UseAllResources $true -ForceNewCluster $true
Write-Output "$(date +%T) Successfully started cluster"

Write-Output "$(date +%T) Deploying core services"
Deploy-SingletonService -Service 'mssql' -Environment 'test'
Deploy-SingletonService -Service 'redis' -Environment 'test'

kubectl rollout status -w deployment.apps/mssql --timeout=10m
if (!$?) {
    throw "Failed to wait for mssql deployment to finish"
}

kubectl rollout status -w deployment.apps/redis --timeout=10m
if (!$?) {
    throw "Failed to wait for redis deployment to finish"
}
Write-Output "$(date +%T) Core services successfully deployed"

Write-Output "$(date +%T) Cleaning the repo and removing .nuget.verify"
rm -f ../obj/.nuget.verify
git clean -ffdx
git reset --hard HEAD
Write-Output "$(date +%T) Successfully cleaned the repo"

Write-Output "$(date +%T) Completed all warmup tasks in $($sw.Elapsed)"
