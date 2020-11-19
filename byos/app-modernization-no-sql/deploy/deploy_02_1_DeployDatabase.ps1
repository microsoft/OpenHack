#TODO: MAP THIS to the correct URL for branch merging!
#$templateUri = "https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/app-modernization-no-sql/deploy/azuresqldatabase.json"

$templateUri = "https://raw.githubusercontent.com/opsgilitybrian/OpenHack/update-nosql-byos-deploy-process/byos/app-modernization-no-sql/deploy/azuresqldatabase.json";

$outputs = New-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroup1Name `
            -location $location1 `
            -TemplateUri $templateUri `
            -sqlserverName $sqlserverName `
            -sqlAdministratorLogin $sqlAdministratorLogin `
            -sqlAdministratorLoginPassword $(ConvertTo-SecureString -String $sqlAdministratorLoginPassword -AsPlainText -Force) `
            -suffix $suffix  

#validate movies database was created.
$dbInstance = Get-AzSqlDatabase -DatabaseName $databaseName -ServerName $sqlserverName -ResourceGroupName $resourceGroup1Name;
if ($dbInstance)
{
    Write-Output "Sql database $databaseName was created successfully!";
}
else
{
    throw "Could not validate existence of deployed database $databaseName";
}
