param (
    [string]$storageAccountName,
    [string]$storageContainerName,
    [string]$storageContainerCsvFolder,
    [string]$containerSAS
)

$src="C:\$storageContainerCsvFolder"
$dest = "C:\Rentals"
$null = New-Item -ItemType Directory -Force -Path $src
#$null = New-Item -ItemType Directory -Force -Path $dest

## REF: https://adamtheautomator.com/azcopy-setup/
$installPath="C:\AzCopy"
#if (Test-Path $InstallPath) {
#    Get-ChildItem $InstallPath | Remove-Item -Confirm:$false -Force
#}

# Zip Destination
#$zip = "$InstallPath\AzCopy.Zip"

# Create the installation folder (eg. C:\AzCopy)
$null = New-Item -Type Directory -Path $InstallPath -Force

# Download AzCopy zip for Windows
Start-BitsTransfer -Source "https://aka.ms/downloadazcopy-v10-windows" -Destination $zip

# Expand the Zip file
Expand-Archive $zip $InstallPath -Force

# Move to $InstallPath
Get-ChildItem "$($InstallPath)\*\*" | Move-Item -Destination "$($InstallPath)\" -Force

#Cleanup - delete ZIP and old folder
Remove-Item $zip -Force -Confirm:$false
Get-ChildItem "$($InstallPath)\*" -Directory | ForEach-Object { Remove-Item $_.FullName -Recurse -Force -Confirm:$false }

# Add InstallPath to the System Path if it does not exist
if ($env:PATH -notcontains $InstallPath) {
    $path = ($env:PATH -split ";")
    if (!($path -contains $InstallPath)) {
        $path += $InstallPath
        $env:PATH = ($path -join ";")
        $env:PATH = $env:PATH -replace ';;',';'
    }
    [Environment]::SetEnvironmentVariable("Path", ($env:path), [System.EnvironmentVariableTarget]::Machine)
}


# It is the responsibility of the caller to ensure that AzCopy.exe is on path
#echo "Copying"
AzCopy.exe cp "https://$storageAccountName.blob.core.windows.net/$storageContainerName/$($storageContainerCsvFolder)?$containerSAS" "C:\" --recursive=true

#echo "Moving $src to $dest"
Move-Item $src $dest

# Subdirectories like "Transactions_2018," no matter what we might add or rename, are moved out to be a sibling of the destination directory
# This leaves only the initial 2017 data in the directory, and prevents accidental recursive data movement in earlier challenges
foreach($subdirectory in (Get-ChildItem -Directory -Path $dest)){
    Move-Item (Join-Path $dest $($subdirectory.Name)) (Join-Path $($dest) '..\')
}