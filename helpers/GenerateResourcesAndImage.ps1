$ErrorActionPreference = 'Stop'

enum ImageType {
    Windows2016 = 0
    Windows2019 = 1
    Ubuntu1604 = 2
    Ubuntu1804 = 3
}

Function Get-PackerTemplatePath {
    param (
        [Parameter(Mandatory = $True)]
        [string] $RepositoryRoot,
        [Parameter(Mandatory = $True)]
        [ImageType] $ImageType
    )

    $relativePath = "N/A"

    switch ($ImageType) {
        ([ImageType]::Windows2016) {
            $relativePath = Join-Path "images" "win" "Windows2016-Azure.json"
        }
        ([ImageType]::Windows2019) {
            $relativePath = Join-Path "images" "win" "Windows2019-Azure.json"
        }
        ([ImageType]::Ubuntu1604) {
            $relativePath = Join-Path "images" "linux" "ubuntu1604.json"
        }
        ([ImageType]::Ubuntu1804) {
            $relativePath = Join-Path "images" "linux" "ubuntu1804.json"
        }
    }

    return Join-Path $RepositoryRoot $relativePath
}

Function GenerateResourcesAndImage {
    <#
        .SYNOPSIS
            A helper function to help generate an image.

        .DESCRIPTION
            Creates Azure resources and kicks off a packer image generation for the selected image type.

        .PARAMETER SubscriptionId
            The Azure subscription Id where resources will be created.

        .PARAMETER ResourceGroupName
            The Azure resource group name where the Azure resources will be created.

        .PARAMETER ImageGenerationRepositoryRoot
            The root path of the image generation repository source.

        .PARAMETER ImageType
            The type of the image being generated. Valid options are: {"Windows2016", "Windows2019", "Ubuntu1604", "Ubuntu1804"}.

        .PARAMETER AzureLocation
            The location of the resources being created in Azure. For example "East US".

        .PARAMETER Force
            Delete the resource group if it exists without user confirmation.

        .PARAMETER GithubFeedToken
            GitHub PAT to download tool packages from GitHub Package Registry

        .EXAMPLE
            GenerateResourcesAndImage -SubscriptionId {YourSubscriptionId} -ResourceGroupName "shsamytest1" -ImageGenerationRepositoryRoot "C:\virtual-environments" -ImageType Ubuntu1604 -AzureLocation "East US"
    #>
    param (
        [Parameter(Mandatory = $True)]
        [string] $SubscriptionId,
        [Parameter(Mandatory = $True)]
        [string] $ResourceGroupName,
        [Parameter(Mandatory = $True)]
        [string] $ImageGenerationRepositoryRoot,
        [Parameter(Mandatory = $True)]
        [ImageType] $ImageType,
        [Parameter(Mandatory = $True)]
        [string] $AzureLocation,
        [Parameter(Mandatory = $False)]
        [int] $SecondsToWaitForServicePrincipalSetup = 30,
        [Parameter(Mandatory = $False)]
        [string] $GithubFeedToken,
        [Parameter(Mandatory = $False)]
        [Switch] $Force
    )

    if (([string]::IsNullOrEmpty($GithubFeedToken)))
    {
        Write-Error "'-GithubFeedToken' parameter is not specified. You have to specify valid GitHub PAT to download tool packages from GitHub Package Registry"
        exit 1
    }

    $builderScriptPath = Get-PackerTemplatePath -RepositoryRoot $ImageGenerationRepositoryRoot -ImageType $ImageType
    $InstallPassword = $env:UserName + [System.GUID]::NewGuid().ToString().ToUpper();

    #az login
    az account set --subscription $SubscriptionId

    $rg = $null
    $alreadyExists = $(az group exists --name $ResourceGroupName)
    if ($alreadyExists -eq $true) {
        # Cleanup the resource group if it already exitsted before
        $rg = $(az group list --query "[?name=='$ResourceGroupName']" | ConvertFrom-Json)
        if ($rg.location -ne $AzureLocation.ToLower().Replace(' ', '')) {
            Write-Host "Deleting resource group $ResourceGroupName since the location is not correct"
            az group delete --yes --name $ResourceGroupName
            $rg = $null
        }
    }

    if ($null -eq $rg) {
        Write-Host "Creating resource group $ResourceGroupName in $AzureLocation"
        az group create --name $ResourceGroupName --location $AzureLocation
    }

    # This script should follow the recommended naming conventions for azure resources
    $storageAccountName = if($ResourceGroupName.EndsWith("-rg")) {
        $ResourceGroupName.Substring(0, $ResourceGroupName.Length - 3)
    } else { $ResourceGroupName }

    # Resource group names may contain special characters, that are not allowed in the storage account name
    $storageAccountName = $storageAccountName.Replace("-", "").Replace("_", "").Replace("(", "").Replace(")", "").ToLower()
    $storageAccountName += "001"

    $storageAccount = $(az storage account list --query "[?name=='patcarnaimg001']" | ConvertFrom-Json)
    if ($null -eq $storageAccount) {
        az storage account create --resource-group $ResourceGroupName --name $storageAccountName --location $AzureLocation --sku "Standard_LRS"
    }

    $spDisplayName = "$($ResourceGroupName)_builder"
    $sp = $(az ad sp list --filter "displayname eq '$spDisplayName'" | ConvertFrom-Json)
    if ($null -eq $sp) {
        Write-Host "Creating service principal $spDisplayName"
        $sp = $(az ad sp create-for-rbac --name $spDisplayName --role Contributor  | ConvertFrom-Json)
        $env:IMAGE_BUILDER_SP_SECRET = $sp.Password

        Write-Host "Sleeping for AD roles to propagate"
        Start-Sleep -Seconds $SecondsToWaitForServicePrincipalSetup
    } 
    else {
        if ($null -eq $env:IMAGE_BUILDER_SP_SECRET) {
            # reset the credentials so we can get the new password out
            Write-Host "Resetting service principal credentials for $($sp.appId)"
            $sp = $(az ad sp credential reset --name $sp.appId | ConvertFrom-Json)
            $env:IMAGE_BUILDER_SP_SECRET = $sp.password

            Write-Host "Sleeping for AD roles to propagate"
            Start-Sleep -Seconds $SecondsToWaitForServicePrincipalSetup
        }
    }

    $spClientId = $sp.appId
    $spClientSecret = $sp.password
    $spObjectId = $(az ad sp list --filter "displayname eq '$spDisplayName'" | ConvertFrom-Json).objectId
    $tenantId = $sp.tenant

    # "", "Note this variable-setting script for running Packer with these Azure resources in the future:", "==============================================================================================", "`$spClientId = `"$spClientId`"", "`$ServicePrincipalClientSecret = `"$ServicePrincipalClientSecret`"", "`$SubscriptionId = `"$SubscriptionId`"", "`$tenantId = `"$tenantId`"", "`$spObjectId = `"$spObjectId`"", "`$AzureLocation = `"$AzureLocation`"", "`$ResourceGroupName = `"$ResourceGroupName`"", "`$storageAccountName = `"$storageAccountName`"", "`$install_password = `"$install_password`"", ""

    packer build -on-error=ask `
        -var "client_id=$($spClientId)" `
        -var "client_secret=$($spClientSecret)" `
        -var "subscription_id=$($SubscriptionId)" `
        -var "tenant_id=$($tenantId)" `
        -var "object_id=$($spObjectId)" `
        -var "location=$($AzureLocation)" `
        -var "resource_group=$($ResourceGroupName)" `
        -var "storage_account=$($storageAccountName)" `
        -var "install_password=$($InstallPassword)" `
        -var "github_feed_token=$($GithubFeedToken)" `
        $builderScriptPath
}
