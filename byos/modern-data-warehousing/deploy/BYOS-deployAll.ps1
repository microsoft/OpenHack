param(
    [string]$teamCount = "1",
    [string]$DeploymentTemplateFile = ".\DeployMDWOpenHackLab.json",
    [string]$DeploymentParameterFile = ".\DeployMDWOpenHackLab.parameters.json",
    [string]$Location = "eastus",
    [securestring]$SqlAdminLoginPassword,
    [securestring]$VMAdminPassword,
    [securestring]$BackupStorageContainerSAS
)
$teamCount = Read-Host "How many teams are hacking?";
$region = Read-Host "What Region Resources be deployed to (i.e. centralus, southcentralus, japaneast, etc)?";

for ($i = 1; $i -le $teamCount; $i++)
{
    $teamName = $i;
    if ($i -lt 10)
    {
        $teamName = "0" + $i;
    }
    
    $resourceGroupName = "mdw-oh-" + $teamName + "-" + $region
    $deploymentName = "azuredeploy" + "-" + (Get-Date).ToUniversalTime().ToString('MMdd-HHmmss')
    Write-Host("Now deploying RG to " + $resourceGroupName);

    New-AzResourceGroup -Name $resourceGroupName -Location $region

    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorVariable notPresent -ErrorAction SilentlyContinue
    if (!$resourceGroup) {
        $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $region
    }
    New-AzResourceGroupDeployment -Name $deploymentName -ResourceGroupName $resourceGroupName -Location $region -TemplateFile $DeploymentTemplateFile -TemplateParameterFile $DeploymentParameterFile -SqlAdminLoginPassword $SqlAdminLoginPassword -VMAdminPassword $VMAdminPassword -BackupStorageContainerSAS $BackupStorageContainerSAS -AsJob    
}
