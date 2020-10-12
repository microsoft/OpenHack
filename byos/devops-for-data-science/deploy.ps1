[CmdletBinding()]
param( 
    # The location for the resource group
    [string]
    $Location = 'West US 2',

    # The resource group name
    [string]
    $ResourceGroupName = "oh-dsdata-data",

    # Prefix for the storage account name
    [string]
    $StoragePrefix = "dsdata",

    # Name for the blobstore container
    [string]
    $ContainerName = "data",

    # Name for the blob
    [string]
    $BlobName = "porto_seguro_safe_driver_prediction_input.csv.zip",

    # Local file path for the zipped training data
    [string]
    $TrainSource
)

### Validate parameters

$storageAccountName = $StoragePrefix + [System.IO.Path]::GetRandomFileName().Substring(0,7)

if (!(Test-Path $TrainSource)) {
    Write-Error "$TrainSource is not a valid path"
    exit 1
}

### Create the Resource Group

$resourceGroup = New-AzResourceGroup `
    -Name $ResourceGroupName `
    -Location $Location `
    -Force `
    -ErrorAction Stop `
    -Verbose:$VerbosePreference

### Deploy the ARM template (approx 60 seconds)

$templatePath = Join-Path $PSScriptRoot "azuredeploy.json"

$arDeployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $ResourceGroupName `
    -TemplateFile $templatePath `
    -storageAccountName $storageAccountName `
    -containerName $ContainerName `
    -ErrorAction Stop `
    -Verbose:$VerbosePreference

### Copy the challenge files and data to blobstore (approx 60 seconds)

$storage = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $storageAccountName
$storageContext = $storage[0].Context

Write-Verbose "Uploading contents of $TrainSource to blob $BlobName"

Set-AzStorageBlobContent `
-Blob $BlobName `
-Container $ContainerName `
-File $TrainSource `
-Context $storageContext `
-Verbose:$VerbosePreference

### Generate a SAS Uri

New-AzStorageBlobSASToken `
    -Container $containerName `
    -Blob $blobName `
    -Context $storageContext `
    -Permission r `
    -FullUri
