param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$containerSAS,
    [string]$databaseName,
    [string]$databaseBackupName,
    [string]$sqlUserName,
    [string]$sqlPassword
)

.\DeploySQLVM.ps1 -storageAccountName $storageAccountName `
    -storageContainerName $storageContainerName `
    -containerSAS $containerSAS `
    -databaseName $databaseName `
    -databaseBackupName $databaseBackupName `
    -sqlUserName $sqlUserName `
    -sqlPassword $sqlPassword

.\DisableIEESC.ps1