param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$storageContainerCsvFolder,
    [string]$containerSAS
)

$dest = "C:\Rentals"

# It is the responsibility of the caller to ensure that AzCopy.exe is on path
AzCopy.exe cp "https://$storageAccountName.blob.core.windows.net/$storageContainerName/$($storageContainerCsvFolder)?$containerSAS" "C:\" --recursive=true
Move-Item "C:\$storageContainerCsvFolder" $dest

# Subdirectories like "Transactions_2018," no matter what we might add or rename, are moved out to be a sibling of the destination directory
# This leaves only the initial 2017 data in the directory, and prevents accidental recursive data movement in earlier challenges
foreach($subdirectory in (Get-ChildItem -Directory -Path $dest)){
    Move-Item (Join-Path $dest $($subdirectory.Name)) (Join-Path $($dest) '..\')
}