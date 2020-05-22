$sw = [System.Diagnostics.Stopwatch]::StartNew()

Set-Location /agent/_work/1/s
./init.ps1
Import-Module ./Scripts/lib/DeploymentUtilities.psm1

Write-Output "Starting minikube cluster actions-dev"
Start-Cluster -Driver 'docker' -UseAllResources $true
Write-Output "Successfully started cluster"

Write-Output "Deploying core services"
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
Write-Output "Core services successfully deployed"

Write-Output "Cleaning the repo and removing .nuget.verify"
rm -f ../obj/.nuget.verify
git clean -ffdx
git reset --hard HEAD
Write-Output "Successfully cleaned the repo"

Write-Output "Completed all warmup tasks in $($sw.Elapsed)"
