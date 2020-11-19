#
#  Import data, run after ensure database
#   Reuquies pre-defined variables: $sqlserverName, $databaseName, $sqlAdministratorLogin, $sqlAdministratorLoginPassword
#

$importRequest = New-AzSqlDatabaseImport -ResourceGroupName $resourceGroup1Name `
            -ServerName $sqlserverName -DatabaseName $databaseName `
            -DatabaseMaxSizeBytes "5000000" `
            -StorageKeyType "SharedAccessKey" `
            -StorageKey "?sp=rl&st=2019-11-26T21:16:46Z&se=2025-11-27T21:36:00Z&sv=2019-02-02&sr=b&sig=P15nBXR2bD2jBnHX92%2BwWRxMnvTeUl3EdBNhLXnZ95s%3D" `
            -StorageUri "https://databricksdemostore.blob.core.windows.net/data/nosql-openhack/movies.bacpac" `
            -Edition "Basic" -ServiceObjectiveName "Basic" `
            -AdministratorLogin $sqlAdministratorLogin `
            -AdministratorLoginPassword $(ConvertTo-SecureString -String $sqlAdministratorLoginPassword -AsPlainText -Force)

$importStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink

[Console]::Write("Importing database")
while ($importStatus.Status -eq "InProgress") {
    $importStatus = Get-AzSqlDatabaseImportExportStatus -OperationStatusLink $importRequest.OperationStatusLink
    [Console]::Write(".")
    Start-Sleep -s 10
}

[Console]::WriteLine("")
$importStatus
