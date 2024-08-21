# Containers OpenHack Deployment

## Prerequisites

### Permissions

To deploy this lab environment, you will need an Azure account that has at least [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#contributor) access to the subscription.

#### Adding Users to the Created Environment

If you plan on adding another user to the resource group after provisioning (for example, if you will be working together with someone else), you will need the [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#owner) or [User Access Administrator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#user-access-administrator) role.

#### Permissions for Challenge 3

The challenge expects two new user accounts created in Azure AD: webdev and apidev to complete the challenge requirements. To add users, you will need the [User Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#user-administrator) or [Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference#global-administrator) role.

If you do not have access to create these user accounts in Azure AD, you can use accounts from members of your team instead.

### Tools

For deploying the lab environment:

- A terminal environment capable of running `bash` scripts
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed locally, or within [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview)
  - If using a local installation, ensure you have the latest version

> Note: Azure Cloud Shell has Azure CLI and tools used in the hack (docker, kubectl, helm) installed already.

Ensure you have logged in to Azure CLI:

```sh
az login
```

and that you have selected the correct Azure subscription:

```sh
az account list
az account set --subscription [subscription name]
```

### Files

You can clone this repository with

```sh
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
| `-l` | Azure region | `westus` |
| `-g` | Azure resource group name for team (attendee) resources | `teamResources` |
| `-o` | Azure resource group name for proctor resources | `proctorResources` |
| `-f` | Suffix (appended to resource group names) | `""` |
| `-u` | Azure username - not necessary if you are logged in to `az` | `""` |
| `-p` | Azure password - not necessary if you are logged in to `az` | `""` |
| `-t` | Azure tenant ID - not necessary if you are logged in to `az`; only required for service principal login | `""` |
| `-s` | Azure subscription ID - not necessary if you have selected the intended subscription with `az account set` | `""` |
| `-a` | Append in order to create Azure users `api-dev` and `web-dev` used in Challenge 3 | false |

### Example Usage

```sh
# uses default variable values
./deploy.sh
```

```sh
# specify region
./deploy.sh -l "eastus2"
```

```sh
# specify a team resource group name and create the api-dev and web-dev users
./deploy.sh -g "openHackTest" -a
```

```sh
# specify region, team resource group name, and suffix
./deploy.sh -l "australiaeast" -g "teamRG" -f "2"
```

```sh
# Logging in with an Azure username and password, and setting a specified subscription
./deploy.sh -u yourUsername@yourTenant.com -p yourPassword -s subscriptionGUID
```

If deploying for multiple teams, run the script once per team using a unique suffix each time:

```sh
# a build for 2 teams in eastus region using default resource group naming

./deploy.sh -l "eastus" -f "1" # creates teamResources1 and proctorResources1
./deploy.sh -l "eastus" -f "2" # creates teamResources2 and proctorResources2
```

### Known Errors

If you're seeing `\r` characters (carriage returns) in your output, check the following:

- If you've cloned the repo on Windows, that's likely added carriage returns. Reclone in a Linux environment or run `sed -i 's/\r//g' deploy.sh`
- If you're in a Linux environment and still having issues, check that your `az` installation is a Linux version, not Windows. In WSL, it's possible to access your Windows applications - which can leave carriage returns on the end of your `az` command responses.

## Provisioned Resources

On deployment, two resource groups will be created with resources in each. The Team Resource Group contains the stage artifacts on which the challenge is run. The Proctor Resource Group acts as a deployment depot and contains a single Azure Container Instance with an image required to load the SQL Server instance in the Team Resource Group.

The following are resources are deployed as part of the deployment script (per team). Throughout the hack, there will be many other resources created.

| Azure resource | Pricing tier/SKU | Purpose | Registered Resource Providers |
| -------------- | ---------------- | ------- | ----------------------------- |
| Azure SQL Database | Standard S3: 100 DTUs | mydrivingDB | Microsoft.Sql |
| Azure Container Registry | Basic | Private container registry | Microsoft.ContainerRegistry |
| Azure Container Instance | 1 CPU core/1.5 GiB RAM | Dataload container | Microsoft.ContainerInstance |
| Azure Container Instance (Container Group) | 2 CPU cores/1.5 GiB RAM; 1 CPU core/1.5 GiB RAM; 1 CPU core/1.5 GiB RAM | Traffic simulator; traffic simulator metrics; traffic simulator dashboard | Microsoft.ContainerInstance |
| Azure Virtual Network | n/a | Network space for Challenge 3 onward | Microsoft.Network |
| Azure Virtual Machine | Standard DS1 | Used to test connectivity within the VNet | Microsoft.Compute |

> Note: Resource Provider Registration can be found at portal.azure.com/_yourTenantName_.onmicrosoft.com/resource/subscriptions/_yourSubscriptionId_/resourceproviders

Several images are built and added to the Azure Container Registry as part of deployment:

| Image name | Purpose |
| ---------- | ------- |
| dataload | Adds data to the SQL database |
| simulator | Traffic simulator which makes calls to attendees' cluster |
| grafana-sim | Grafana dashboard for the traffic simulator |
| prometheus-sim | Metrics for the traffic simulator |
| insurance | Application used in Challenge 5 |
| tripviewer2 | Updated Tripviewer UI used in Challenge 7 |
| wcfservice | Windows application used in Challenge 7 |
