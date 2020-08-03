# Containers OpenHack Deployment

## Setting up Permissions

To deploy this lab environment use an account that has at least Azure Contributor Role Permissions. 

**Initial Setup** 

To initiate a deployment, download the `TeamDeploy` folder content to the same folder as bash script `deployBYOS.sh`, and run the script with the parameters provided below.   The script uses relative paths to execute other scripts within the content folder.

> Note: [Azure Cloud Shell](https://docs.microsoft.com/azure/cloud-shell/overview) will be the easiest to use as it has all of the required tooling (az/sqlcmd/bcp/dig/etc.) installed already.

The current deployment stack requires the following tooling and versions:

- Azure CLI v2.3.0 (or higher) ([Installation instructions](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))
- sqlcmd v17.5.0001.2 Linux (or higher) ([Installaton instructions](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools))
    - bcp
- dig v9.10.3 (or higher)

You can deploy this lab using local azure cli (bash/WSL), via VSCode, or using Azure CloudShell. If you use your local AZ CLI client, ensure you have latest AZ CLI, SQLCMD, and DIG extensions installed.  For reasons, outlined above, Azure CloudShell has all required tools loaded by default, so this is often an easier method. 

## Deployed Azure Resources 

| Azure resource           | Pricing tier/SKU       | Purpose                                 | Registered Resource Providers |
| ------------------------ | ---------------------- | --------------------------------------- | ----------------------------- |
| Azure SQL Database       | Standard S3: 100 DTUs  | mydrivingDB                             | Microsoft.Sql                 |
| Azure Kubernetes Service | Basic                  | Private container service               | Microsoft.ContainerService    |
| Azure Container Registry | Basic                  | Private container registry              | Microsoft.ContainerRegistry   |
| Azure Container Instance | 1 CPU core/1.5 GiB RAM | DataLoad container                      | NA                            |

> Note:  Resource Provider Registration can be found at https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the Open Hack on. 
Ensure they have adequate permissions to perform software installation. 
Attendees require internet access outside of any corpnet VPNs they can cause security and access issues. 

## Deployment Instructions 

On deployment, two resource groups will be created with resources in each.   The Team Resource Group contains the stage artifacts on which the challenge is run.    The Proctor Resource Group acts as a deployment depot and contains a single Azure Container Instance with an image required to load the SQL Server instance in the Team Resource Group.

For deployment, there is only one step: 

You will run a shell script **deploy.sh** with appropriate parameter values that builds out the required resources using Azure CLI calls under the security context of the shell.  

deploy.sh has the following parameters:

| Parameter | Description                                        | Example      |
| --------- | -------------------------------------------------- | ------------ |
|  -r       | Azure region                                       | westus       |  
|  -s       | Team Suffix                                        | _Team4       |
|  -t       | Azure Resource Group Name (default: teamResources) | TeamRG_Team4 |


Consider the following minimal parameter execution: 

```sh
# full default
wsl ./deploy.sh  
```
```sh
# specify region
wsl ./deploy.sh -r "<deploymentregion>" 
```

```sh
# specify region, and custom resource group name
wsl ./deploy.sh -r "<deploymentregion>" -t "<teamresoucegroup>"
```

```sh
# specify region, custom resource group name, and suffix 
wsl ./deploy.sh -r "<deploymentregion>" -t "<teamresoucegroup>" -s "2" 
```

Considering the examples above, the inclusion of a suffix parameter augments both the Team Resource Group name and the Proctor Resource Group name by appending the suffix value.   This is useful when building out several identical stages, individually configured for each team - as such:

```sh
# a build for team 1 and 2 in eastus region using default resource group name
bash deploy.sh -r "eastus" -s "1"  # Build challenge stage for Team 1: teamResources1, proctorResources1
bash deploy.sh -r "eastus" -s "2"  # Build challenge stage for Team 2: teamResources2, proctorResources2

```

> Note: This script builds out significant premium workloads at low scale, but will often take 25-30 minutes on average to execute.  
> 
> Some Azure services are not available in all locations.  Check with Azure Regions to ensure the resources required below are available in a given region prior to deployment.