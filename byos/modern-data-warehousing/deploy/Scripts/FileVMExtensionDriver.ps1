param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$storageContainerCsvFolder,
    [string]$catalogJsonFileName,
    [string]$containerSAS
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module AzureRM -Force

Invoke-WebRequest -Uri https://aka.ms/mdw-oh-azcopy -OutFile azcopy-v10-windows.zip
Expand-Archive -Path azcopy-v10-windows.zip -DestinationPath .
$azcopy = Get-ChildItem -Recurse | Where-Object {$_.Name -ieq "azcopy.exe" }
$env:path += ";$($azcopy.DirectoryName)"

.\RetrieveCSV.ps1 -storageAccountName $storageAccountName -storageContainerName $storageContainerName -storageContainerCsvFolder $storageContainerCsvFolder -containerSAS $containerSAS
.\CreateAndPopulateCosmos.ps1 -storageAccountName $storageAccountName -storageContainerName $storageContainerName -catalogJsonFileName $catalogJsonFileName -containerSAS $containerSAS
.\DisableIEESC.ps1