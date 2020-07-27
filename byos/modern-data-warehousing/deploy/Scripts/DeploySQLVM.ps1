param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$containerSAS,
    [string]$databaseName,
    [string]$databaseBackupName,
    [string]$sqlUserName,
    [string]$sqlPassword
)

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://aka.ms/mdw-oh-azcopy -OutFile azcopy-v10-windows.zip
Expand-Archive -Path azcopy-v10-windows.zip -DestinationPath .
$azcopy = Get-ChildItem -Recurse | Where-Object { $_.Name -ieq "azcopy.exe" }
$env:path += ";$($azcopy.DirectoryName)"

AzCopy.exe cp "https://$($storageAccountName).blob.core.windows.net/$($storageContainerName)/$($databaseBackupName)?$($containerSAS)" ".\$($databaseBackupName)"

$localBackupFile = Get-Item "$($databaseBackupName)"
Invoke-Sqlcmd -Username $sqlUserName -Password $sqlPassword -Query "RESTORE DATABASE $($databaseName) FROM DISK = '$($localBackupFile.FullName)' WITH STATS = 5" -ServerInstance "."