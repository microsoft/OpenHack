# DevOps OpenHack Deployment

## Setting up Permissions

Before continuing ensure you understand the permissions needed to run the Open Hack on your Azure subscription.  

This lab deploys to a single resource group within a subscription.  To deploy this lab environment, ensure the account you use to execute the script is at a minimum in the Azure Contributor Role. 

**Initial Setup** 

To initiate a deployment, download both the ARM template (`azuredeploy.json`) and the bash script (`deploy.sh`) to the same directory in a bash shell.

> Note: [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) will be the easiest to use as it has all of the required tooling (az/sqlcmd/bcp/dig/etc.) installed already.

The current deployment stack requires the following tooling and versions:

- Azure CLI v2.3.0 (or higher) ([Installation instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- sqlcmd v17.5.0001.2 Linux (or higher) ([Installaton instructions](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools))
    - bcp
- dig v9.10.3 (or higher)

You can deploy this lab using local azure cli (bash) or using Azure CloudShell. If you use your local AZ CLI client, ensure you have latest AZ CLI, SQLCMD, and DIG extensions installed.  For reasons, outlined above, Azure CloudShell has all required tools loaded by default, so this is often an easier method. 

## Common Azure Resources 

| Azure resource           | Pricing tier/SKU       | Purpose                                 | Registered Resource Providers |
| ------------------------ | ---------------------- | --------------------------------------- | ----------------------------- |
| Azure SQL Database       | Standard S3: 100 DTUs  | mydrivingDB                             | Microsoft.Sql                 |
| Azure Container Registry | Basic                  | Private container registry              | Microsoft.ContainerRegistry   |
| Azure Container Instance | 1 CPU core/1.5 GiB RAM | Jenkins container                       | NA                            |
| Azure Key Vault          | Standard               | Key vault for database secrets          | Microsoft.KeyVault            |
| App Service Plan         | Standard S1            | App Service Plan for all Azure Web Apps | NA                            |
| Azure Container Instance | 1 CPU core/1.5 GiB RAM | Simulator                               | Microsoft.ContainerInstance   |

> Note:  Resource Provider Registration can be found at https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the Open Hack on. 
Ensure they have adequate permissions to perform software installation. 
Attendees require internet access outside of any corpnet VPNs they can cause security and access issues. 

## Deployment Instructions 

For deployment, there is only one step: 

You will run a shell ** script deploy.sh ** with appropriate parameter values that builds out the required resources using Azure CLI calls under the security context of the shell.  

deploy.sh has only two parameters: -l (location), and -s (suffix).   

Run deploy.sh with a single parameter (`-l` for location). *e.g.* To deploy into `eastus`.  In this case, suffix will be a randomly generated suffix to ensure uniqueness. 

```sh
bash deploy.sh -l eastus -s X  # where X is numbered suffix 

```
Adding the addtional parameter applies a suffix: (`-s` for suffix), using numbers and letters only *e.g.* [^A-Za-z0-9]``.

This is useful to keep the preceding naming pattern, but differentiate deployments for individual teams. So for instance, if you wanted to run the script to build out the lab in the same region, in this case EASTUS, for two teams you might execute:

```sh
bash deploy.sh -l eastus -s 1  # Team 1 
bash deploy.sh -l eastus -s 2  # Team 2
```

The result will be two resource groups in the same sub in eastus with the following name pattern:
 - openhack1rg
 - openhack2rg

> Note: This script builds out significant premium workloads at low scale, but will often take 30-50 minutes on average to execute. 
> 
> Some Azure services are not available in all locations.  Check with Azure Regions to ensure the resources required below are available in a given region prior to deployment.