# Containers OpenHack Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

#### Adding Users to the Created Environment

If you plan on adding another user to the resource group after provisioning (for example, if you will be working together with someone else), you will need the [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) or [User Access Administrator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) role.

#### Permissions for Challenge 4

The challenge expects two new user accounts created in Azure AD: webdev and apidev to complete the challenge requirements.
If you do not have access to create these user accounts in Azure AD you can use accounts from members of your team instead.

### Tools

For deploying the lab environment:

- A terminal environment capable of running `bash` scripts
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
  - If using a local installation, ensure you have the latest updates

> Note: Azure Cloud Shell has Azure CLI and tools used in the hack (docker, kubectl, helm) installed already.

Ensure you have logged in to Azure CLI:

```bash
az login
```

and that you have selected the correct Azure subscription:

```bash
az account list
az account set --subscription [subscription name]
```

### Files

You can clone this repository with

```bash
git clone https://github.com/microsoft/openhack 
```

The deployment script expects to be run from the [`byos/containers/deploy`](./deploy) directory. Scripts use relative paths based on that expectation.

## Deployment

[`deploy.sh`](./deploy/deploy.sh) will perform all needed provisioning.

> Note: This script will often take 10-20 minutes on average to execute.  
>
> Some Azure services are not available in all locations.  Check with Azure Regions to ensure the resources required below are available in a given region prior to deployment.

### Parameters

| Flag | Description | Default Value |
| --------- | ----------- | ------------- |
| `-r` | Azure region | `westus` |
| `-t` | Azure resource group name for team (attendee) resources | `teamResources` |
| `-p` | Azure resource group name for proctor resources | `proctorResources` |
| `-s` | Suffix (appended to resource group names) | `""` |
| `-a` | Set in order to create Azure users `api-dev` and `web-dev` used in Challenge 4 | false |

### Example Usage

```sh
# uses default variable values
./deploy.sh
```

```sh
# specify region
./deploy.sh -r "eastus2"
```

```sh
# specify a resource group name and create the api-dev and web-dev users
./deploy.sh -t "openHackTest" -a
```

```sh
# specify region, resource group name, and suffix
./deploy.sh -r "australiaeast" -t "teamRG" -s "2"
```

If deploying for multiple teams, run the script once per team using a unique suffix each time:

```sh
# a build for 2 teams in eastus region using default resource group naming

./deploy.sh -r "eastus" -s "1" # creates teamResources1 and proctorResources1
./deploy.sh -r "eastus" -s "2" # creates teamResources2 and proctorResources2
```

## Provisioned Resources

On deployment, two resource groups will be created with resources in each. The Team Resource Group contains the stage artifacts on which the challenge is run. The Proctor Resource Group acts as a deployment depot and contains a single Azure Container Instance with an image required to load the SQL Server instance in the Team Resource Group.

The following are resources are deployed as part of the deployment script (per team). Throughout the hack, there will be many other resources created.

| Azure resource | Pricing tier/SKU | Purpose | Registered Resource Providers |
| -------------- | ---------------- | ------- | ----------------------------- |
| Azure SQL Database | Standard S3: 100 DTUs | mydrivingDB | Microsoft.Sql |
| Azure Kubernetes Service| Basic | Private container service | Microsoft.ContainerService |
| Azure Container Registry | Basic | Private container registry | Microsoft.ContainerRegistry |
| Azure Container Instance | 1 CPU core/1.5 GiB RAM | DataLoad container | Microsoft.ContainerInstance |
| Azure Virtual Machine | Standard DS1 |  | Microsoft.Compute |

> Note: Resource Provider Registration can be found at portal.azure.com/_yourTenantName_.onmicrosoft.com/resource/subscriptions/_yourSubscriptionId_/resourceproviders
