# 
# Create the sql server
# requires variables for $resourceGroup1Name, $location1, $resourceGroup2Name, $location2
#                           , $sqlserverName, $sqlAdministratorLogin, $sqlAdministratorLoginPassword
#                           , $suffix, $suffix2
$templateUri = "https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/app-modernization-no-sql/deploy/azuredeploy.json"

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

#validate EventHub namespace RG1
$eh1Name = "openhackhub-$suffix";
$eh1 = Get-AzEventHub -ResourceGroupName $resourceGroup1Name -Namespace $eh1Name;
if ($eh1)
{
    Write-Output "EventHub namespace 1 created successfully: $eh1Name";
}
else
{
    throw "Could not validate existence of deployed event hub $eh1Name";
}

$eh2Name = "openhackhub-$suffix2"
$eh2 = Get-AzEventHub -ResourceGroupName $resourceGroup2Name -Namespace $eh2Name;
if ($eh2)
{
    Write-Output "EventHub namespace 2 created successfully: $eh2Name";
}
else
{
    throw "Could not validate existence of deployed event hub $eh2Name";
}
Write-Output "All base resources are deployed and validated.";

#validate SQL SERVER
$sqlServerInstance = Get-AzSqlServer -ResourceGroupName $resourceGroup1Name -ServerName $sqlserverName;
if ($sqlServerInstance)
{
    Write-Output "Sql server created: $sqlserverName";
}
else
{
    throw "Could not validate existence of deployed sql server: $sqlserverName";
}

#validate AppService Plan
$aspPlanName = "openhackplan-$suffix";
$appServicePlan = Get-AzAppServicePlan -ResourceGroupName $resourceGroup1Name -Name $aspPlanName
if ($appServicePlan)
{
    Write-Output "App service plan created successfully: $aspPlanName";
}
else {
    throw "Could not validate existence of deployed app service plan $aspPlanName";
}

#validate web app
$aspWebAppName = "openhackweb-$suffix"
$appServiceInstance = Get-AzWebApp -ResourceGroupName $resourceGroup1Name -Name $aspWebAppName
if ($appServiceInstance)
{
    Write-Output "App service Web created successfully: $aspWebAppName";
}
else {
    throw "Could not validate existence of deployed app service web $aspWebAppName";
}
