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

Write-Output "$(date +%T) Updating mssql deployment for optimal performance"
$cpus = Get-LogicalCPUCount
for ($fileNum = 2; $fileNum -le $cpus; $fileNum++) {
    Write-Host "Adding tempdb file $fileNum"
    $query = "ALTER DATABASE [tempdb] ADD FILE (NAME = 'tempdev${fileNum}', FILENAME = '/data/mssql/data/tempdb_mssql_${fileNum}.ndf', SIZE = 8MB, FILEGROWTH = 64MB)"
    kubectl exec deployment.apps/mssql -- /opt/mssql-tools/bin/sqlcmd -U SA -P SqlPassw0rd -Q $query
}

kubectl exec deployment.apps/mssql -- /opt/mssql/bin/mssql-conf traceflag 3979 on
kubectl exec deployment.apps/mssql -- /opt/mssql/bin/mssql-conf set control.writethrough 0
kubectl exec deployment.apps/mssql -- /opt/mssql/bin/mssql-conf set control.alternatewritethrough 0
kubectl scale deployment mssql --replicas=0
kubectl scale deployment mssql --replicas=1
Write-Output "$(date +%T) Successfully updated mssql deployment with $cpus tempdb files"

Write-Output "$(date +%T) Cleaning the repo and removing .nuget.verify"
rm -f ../obj/.nuget.verify
git clean -ffdx
git reset --hard HEAD
Write-Output "$(date +%T) Successfully cleaned the repo"

Write-Output "$(date +%T) Completed all warmup tasks in $($sw.Elapsed)"
