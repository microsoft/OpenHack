# DevOps OpenHack Deployment for Azure DevOps

## Setting up permissions

Before continuing ensure you understand the permissions needed to run the OpenHack on your Azure subscription and on your Azure DevOps organization.

This lab deploys to a single resource group within a Azure subscription. To deploy this lab environment, ensure the account you use to execute the script got Azure Contributor Role.

## Prerequisites

- [Azure Subscription](https://azure.microsoft.com/) with [Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role
- [Azure DevOps organization](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops) with [Project Collection Administrators](https://docs.microsoft.com/en-us/azure/devops/organizations/security/lookup-organization-owner-admin?view=azure-devops#show-members-of-the-project-collection-administrators-group) membership
- Linux Bash ([Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/) works too)
- [Azure CLI 2.28.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) or higher

> **Note** [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is supported for Azure DevOps deployment scenario.

## Expected resources

### azuresp.json

The `deploy-ado.sh` script creates `azuresp.json` file with Service Principal credentials. Service Principal has **Contributor** role and it's dedicated for the OpenHack only.

### Azure

| Azure resource        | Pricing tier/SKU | Purpose                            | Registered Resource Providers |
| --------------------- | ---------------- | ---------------------------------- | ----------------------------- |
| Azure Resource Group  | N/A              | Resource Group for Terraform state | N/A                           |
| Azure Storage Account | Standard_LRS     | Storage for Terraform state        | Microsoft.Storage             |

### Azure DevOps

| Azure DevOps resource | Name                           | Purpose                                                                 |
| --------------------- | ------------------------------ | ----------------------------------------------------------------------- |
| Project               | N/A                            | Project for team members                                                |
| Repository            | N/A                            | Git repository with OpenHack files                                      |
| Service Connection    | AzureServiceConnection         | Service Connection for AzureRM with Service Principal from azuresp.json |
| Variable              | LOCATION                       | Variable with Azure location for resources                              |
| Variable              | RESOURCES_PREFIX               | Variable with Resources Prefix used for resources                       |
| Variable              | TFSTATE_RESOURCES_GROUP_NAME   | Variable with Resource Group for Terraform state                        |
| Variable              | TFSTATE_STORAGE_ACCOUNT_NAME   | Variable with Storage Account for Terraform state                       |
| Variable              | TFSTATE_STORAGE_CONTAINER_NAME | Variable with Storage Container for Terraform states                    |
| Variable              | TFSTATE_KEY                    | Variable with State Key for Terraform state                             |

## Deployments Steps

### Azure pre-deployment steps

Login to your Azure Subscription.

```bash
az login
```

Make sure your login context uses right Azure Subscription.

```bash
az account show
```

If not, then change to your Azure Subscription dedicated for the OpenHack.

```bash
az account set --subscription <subscriptionId>
```

Verify your account permissions for the subscription. Expected value: `Contributor` or `Owner`.

```bash
az role assignment list --assignee $(az account show --output tsv --query user.name) --output tsv --query [].roleDefinitionName
```

### Azure DevOps pre-deployment steps

(optional) Create new Azure DevOps organization. Follow this guide how to do it: [Create an organization](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops#create-an-organization)

> **Note** New Azure DevOps organization dedicated only for the OpenHack is highly recommended!

Login to your [Azure DevOps](https://dev.azure.com) organization and [Create a Personal Access Token](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-a-pat) with scope: `TODO`. Then set environment variable `AZURE_DEVOPS_EXT_PAT` with generated token.

```bash
export AZURE_DEVOPS_EXT_PAT="<AzureDevOpsPAT>"
```

### Deployment

Run `deploy-ado.sh` bash script to start Azure & Azure DevOps configuration.

```bash
./deploy-ado.sh -l <AzureLocation> -o <GitHubOrgName> [-t <TeamName>]
```

> **Defaults for optional parameters**
>
> -t TeamName = randomly generated number with 5 digits

### Azure post-deployment steps

Add OpenHack team members to Azure Subscription with **Contributor** role, follow guide: [Assign Azure roles using the Azure portal
](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

### Azure DevOps post-deployment steps

Add OpenHack team members to Azure DevOps Project Team, follow guide: [Add users or groups to a team](https://docs.microsoft.com/en-us/azure/devops/organizations/security/add-users-team-project?view=azure-devops&tabs=preview-page#add-users-or-groups-to-a-team)
