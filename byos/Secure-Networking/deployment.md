# Secure Networking OpenHack Deployment

## Prerequisites

### Permissions
To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.


### Tools

For deploying the OpenHack environment you will need one of the following:

- [Azure PowerShell](https://learn.microsoft.com/powershell/azure/install-az-ps?view=azps-8.3.0) installed locally, or within[Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview)
- If using a local installation, ensure you have the latest version


## Deployment

> Note: This script will often take 15-30 minutes on average to execute.  


If using PowerShell: 

1. Sign in to Azure:

    ```Powershell
    Connect-AzAccount
    ```
1. Deploy the script     

    ```Powershell    
    $RGname = 'cmc-on-prem'
    $location = 'eastus'

    New-AzResourceGroup -Name $RGname -Location $location

    New-AzResourceGroupDeployment -ResourceGroupName $RGname -TemplateFile onpremdeploy.json
    ```
If using CLI

1. Sign in to Azure:

```sh
az login
```

1. Deploy the script 

```sh
 $RGname = 'cmc-on-prem'
 $location = 'eastus'

az group create --name $RGname --location $location
az deployment group create --resource-group $RGname --template-file onpremdeploy.json            
```

## Provisioned Resources


The following are resources are deployed as part of the deployment script (per team). Throughout the hack, there will be many other resources created.

| Azure resource | Pricing tier/SKU | Purpose | 
| -------------- | ---------------- | ------- |
| Azure Virtual Network | n/a | Network space for on premises | 
| Azure Bastion | Basic | Securely connect to Azure VMs |  
| Azure Local network gateway | n/a | Represents CMC's Azure network address space | 
| Azure Network Security Group| n/a | Bastion subnet, data subnet, and mgmt subnet NSG |
| Azure Public IP | Standard | Bastion Public IP | 
| Azure Public IP | Basic | on-prem VPN gateway public IP | 
| Azure Virtual Machine | Standard D2S v3 | SQL VM |
| Azure Virtual Machine | Standard A1 v2 | Windows VM |
| Azure Virtual Network Gateway | Basic | On-prem Gateway |






