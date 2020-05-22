$image_name='actions_20200522_1'
$resource_group='patcarnatest'
$location='Central US'
$osdisk_url='https://patcarnatest001.blob.core.windows.net/system/Microsoft.Compute/Images/images/packer-osDisk.508c4ee4-1d05-4180-a2c6-ba20704986a6.vhd'
$vmss_name='patcarnaactions'

az image create `
    --name $image_name `
    --resource-group $resource_group `
    --source  $osdisk_url `
    --location $location `
    --os-type Linux `
    --storage-sku Premium_LRS `
    --os-disk-caching ReadWrite

az vmss create `
    --name $vmss_name `
    --resource-group $resource_group `
    --image $image_name `
    --vm-sku Standard_DS3_v2 `
    --storage-sku Premium_LRS `
    --authentication-type SSH `
    --instance-count 1 `
    --disable-overprovision `
    --upgrade-policy-mode manual `
    --load-balancer '""'
