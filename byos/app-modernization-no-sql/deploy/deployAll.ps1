#NOTE: This script is modified based off of the script deploy.ps1 located here: https://github.com/solliancenet/nosql-openhack
#       Validate that nothing has changed on that script to this script before proceeding

$teamCount = Read-Host "How many teams are hacking?";
#get-azlocation | Select Location, DisplayName | Format-Table
$location1 = Read-Host "What is the first location to deploy to (i.e. eastus)?";
$location2 = Read-Host "What is the second location to deploy to (i.e. westus)?"

# Enter the SQL Server username (i.e. openhackadmin)
$sqlAdministratorLogin = "openhackadmin"
# Enter the SQL Server password (i.e. Password123)
$sqlAdministratorLoginPassword = "Password123"

for ($i = 1; $i -le $teamCount; $i++)
{
    $teamName = $i;
    if ($i -lt 10)
    {
        $teamName = "0" + $i;
    }
    Write-Output ("Beginning Deployment - " + $teamName);
    $suffix = -join ((48..57) + (97..122) | Get-Random -Count 13 | % {[char]$_})
    $suffix2 = -join ((48..57) + (97..122) | Get-Random -Count 13 | % {[char]$_})
    $databaseName = "Movies"
    $sqlserverName = "openhacksql-" + $teamName + "-" + $suffix

    $resourceGroup1Name = "nosql-" + $teamName + "-openhack1";
    $resourceGroup2Name = "nosql-" + $teamName + "-openhack2";

    New-AzResourceGroup -Name $resourceGroup1Name -Location $location1
    New-AzResourceGroup -Name $resourceGroup2Name -Location $location2

    $rg1 = Get-AzResourceGroup -Name $resourceGroup1Name
    $rg1 = Get-AzResourceGroup -Name $resourceGroup2Name
    if ($rg1.Name -ne '' -and $rg2.Name -ne '')
    {
        $templateUri = "https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/app-modernization-no-sql/deploy/azuredeploy.json"

        Write-Output ("Starting RG Deployment")
        $outputs = New-AzResourceGroupDeployment `
            -ResourceGroupName $resourceGroup1Name `
            -location $location1 `
            -TemplateUri $templateUri `
            -secondResourceGroup $resourceGroup2Name `
            -secondLocation $location2 `
            -sqlserverName $sqlserverName `
            -sqlAdministratorLogin $sqlAdministratorLogin `
            -sqlAdministratorLoginPassword $(ConvertTo-SecureString -String $sqlAdministratorLoginPassword -AsPlainText -Force) `
            -suffix $suffix `
            -suffix2 $suffix2

        Write-Output ("RG Deployment Completed, Import data starting")

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

        Write-Output ("Import data completed")
        
        $webUrl = "https://openhackweb-" + $suffix + ".azurewebsites.net"
        [Console]::WriteLine("Checking Website Availability")
        $availabilityResult = Invoke-WebRequest $webUrl
        
        if($availabilityResult.StatusCode -eq 200) {
            Write-Output ("Website is available")
        }
        else {
            Write-Output("Website availability check failed for team: " + $teamName)
        }
    }
    else
    {
        Write-Output("Deployment failed for team: " + $teamName)
    }

    Write-Output ("Deployment Completed - " + $teamName);
}
