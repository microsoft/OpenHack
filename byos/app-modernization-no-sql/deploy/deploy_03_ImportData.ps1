#
#  Import data, run after ensure database
#   Reuquies pre-defined variables: $sqlserverName, $databaseName, $sqlAdministratorLogin, $sqlAdministratorLoginPassword
#

$importRequest = New-AzSqlDatabaseImport -ResourceGroupName $resourceGroup1Name `
            -ServerName $sqlserverName -DatabaseName $databaseName `
            -DatabaseMaxSizeBytes "2147483648" `
            -StorageKeyType "SharedAccessKey" `
            -StorageKey "?sp=r&st=2021-06-16T20:01:06Z&se=2028-06-17T04:01:06Z&spr=https&sv=2020-02-10&sr=b&sig=WWkTG8VN%2FuazkAiFu9QxYraJTp1bKEwMJj%2Fz6IimUOc%3D" `
            -StorageUri "https://openhackguides.blob.core.windows.net/no-sql-artifacts/movies.bacpac" `
            -Edition "Standard" -ServiceObjectiveName "S0" `
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
