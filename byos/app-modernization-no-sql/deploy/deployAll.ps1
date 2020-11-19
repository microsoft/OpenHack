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
    try 
    {
        $teamName = $i.ToString().PadLeft(2, '0');
        Write-Output ("Beginning Deployment - " + $teamName);

        #create variables for resource group names, database and server names, 
        #and the suffixes to make resources unique
        $resourceGroup1Name = "nosql-" + $teamName + "-openhack1";
        $resourceGroup2Name = "nosql-" + $teamName + "-openhack2";
        #unique strings for creating resources in the provisioned regions    
        $suffix = -join ((48..57) + (97..122) | Get-Random -Count 13 | % {[char]$_});
        $suffix2 = -join ((48..57) + (97..122) | Get-Random -Count 13 | % {[char]$_});
        
        $databaseName = "Movies";
        $sqlserverName = "openhacksql-" + $teamName + "-" + $suffix;

        ## Create the Resource Groups ##  
        $DeployRGsScriptPath = Split-Path $MyInvocation.InvocationName
        & "$DeployRGsScriptPath\deploy_01_DeployResourceGroups.ps1";

        $rg1 = Get-AzResourceGroup -Name $resourceGroup1Name;
        $rg2 = Get-AzResourceGroup -Name $resourceGroup2Name;

        # Write-Output $rg1;
        # Write-Output $rg2;
        
        if ($rg1 -ne $null -and $rg2 -ne $null -and $rg1.Name -ne '' -and $rg2.Name -ne '')
        {
            #Create Eventhubs in each rg, sql server and app service plan and app service in RG1:  
            Write-Output "Starting resource deployments";
            
            $DeployResourcesScriptPath = Split-Path $MyInvocation.InvocationName
            & "$DeployResourcesScriptPath\deploy_02_DeployResources.ps1"

            Write-Output ("Resource deployments completed and validated.");

            #Create the Movies database
            Write-Output ("Starting deployment of Movies database");

            $DeployResourcesScriptPath = Split-Path $MyInvocation.InvocationName
            & "$DeployResourcesScriptPath\deploy_02_1_DeployDatabase.ps1"

            Write-Output ("Database deployment completed.");

            # Import data to the Movies database: 
            Write-Output ("Import data to Movies database is starting (takes upwards of 20 minutes");

            $DeployResourcesScriptPath = Split-Path $MyInvocation.InvocationName
            & "$DeployResourcesScriptPath\deploy_03_ImportData.ps1"
            
            Write-Output ("Data import to the Movies database is complete"); 

            #final validation checks
            Write-Output ("Running final checks and validation scripts.");

            $DeployResourcesScriptPath = Split-Path $MyInvocation.InvocationName
            & "$DeployResourcesScriptPath\deploy_04_FinalValidation.ps1"

            Write-Output ("Final checks completed and validated - " + $teamName); 

            #report complete for team
            Write-Output ("Deployment Completed Successfully - Team: " + $teamName);
        }
        else
        {
            #report error for incorrect RG deployment
            Write-Output("Deployment failed for team: " + $teamName + ". Resource Groups could not be found.");
        }
    }
    catch {
        #report error, team deployment failure
        Write-Output "An error was encountered, script could not complete:  $($PSItem.ToString())";
    }
}

#report operation completed
Write-Output "All resources are deployed.  Operation completed!";
