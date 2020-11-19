# 
#   Run a script to create the two resource groups, deleting the group if it exists or throwing an error
#   Relies on being run from context with preset variables for $resourceGroup1Name, $resourceGroup2Name, $location1, $location2
#
Write-Output "Creating Resource Groups: [$resourceGroup1Name, $resourceGroup2Name]";

#Ensure first resource group
Get-AzResourceGroup -Name $resourceGroup1Name -ErrorVariable notPresent -ErrorAction SilentlyContinue

if ($notPresent)
{
    # ResourceGroup doesn't exist
    New-AzResourceGroup -Name $resourceGroup1Name -Location $location1
}
else
{
    $rebuild = Read-Host "Resource Group '$resourceGroup1Name' exists.  To continue, you must delete the original group and all resources in the group.  Proceed [y/n]";
    if ($rebuild.StartsWith("y","CurrentCultureIgnoreCase"))
    {
        Remove-AzResourceGroup -Name $resourceGroup1Name;
        New-AzResourceGroup -Name $resourceGroup1Name -Location $location1;
    }
    else
    {
        throw "Operation cancelled by user input";
    }
}
    
#Ensure second resource group
Get-AzResourceGroup -Name $resourceGroup2Name -ErrorVariable notPresent2 -ErrorAction SilentlyContinue

if ($notPresent2)
{
    # ResourceGroup doesn't exist
    New-AzResourceGroup -Name $resourceGroup2Name -Location $location2;
}
else
{
    $rebuild2 = Read-Host "Resource Group '$resourceGroup2Name' exists.  To continue, you must delete the original group and all resources in the group.  Proceed [y/n]";
    if ($rebuild2.StartsWith("y","CurrentCultureIgnoreCase"))
    {
        Remove-AzResourceGroup -Name $resourceGroup2Name;
        New-AzResourceGroup -Name $resourceGroup2Name -Location $location2;
    }
    else
    {
        throw "Operation cancelled by user input";
    }
}
    
Write-Output "Deployment of Resource Groups completed";
