# DevOps OpenHack Deployment for GitHub

## Setting up permissions

Before continuing, ensure you understand the permissions needed to run the OpenHack on your Azure subscription and your GitHub organization.

This lab deploys to a single resource group within an Azure subscription. To deploy this lab environment, ensure the account you use to execute the script got the Azure Owner Role.

## Prerequisites

- [Azure Subscription](https://azure.microsoft.com/) with [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role
- [GitHub Organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/about-organizations) within [GitHub Enterprise Cloud](https://docs.github.com/en/get-started/learning-about-github/githubs-products#github-enterprise) with [GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- Linux Bash ([Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/) works too)
- [Azure CLI 2.32.0](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) or higher
- [GitHub CLI 2.5.0](https://cli.github.com/) or higher
- [jq 1.5](https://stedolan.github.io/jq/download/) or higher

> **NOTE** [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview) is **supported** for GitHub deployment scenario, and it's recommended solution.

### GitHub Organization membership

Each OpenHack team will create **their own GitHub team within the GitHub organization that has already been created for all DevOps OpenHacks**.

Default GitHub Org for this OpenHack is: [DevOpsOpenHack](https://github.com/DevOpsOpenHack)

- **Tech Lead** should be added to the GitHub organization prior to each OpenHack by the Open Hack **Program Team** with *Owner* role.
- **Coaches** should be added to the GitHub organization prior each OpenHack by the OpenHack **Tech Lead** with *Owner* role.
- **Attendees** should be added to the GitHub organization at the beginning on each OpenHack by the **Coach**  with *Member* role.

Make sure your OpenHack team members are part of a dedicated GitHub organization. If not, then invite them. Follow this guide on how to do it: [Inviting users to join your organization](https://docs.github.com/en/organizations/managing-membership-in-your-organization/inviting-users-to-join-your-organization)

## Expected resources

### azuresp.json

The `deploy-gh.sh` script creates `azuresp.json` file with Service Principal credentials. Service Principal has **Owner** role, and it's dedicated for the OpenHack only.

> **NOTE** Please keep this file for future use by your team members.

### Azure

| Azure resource        | Pricing tier/SKU | Purpose                            | Resource Providers |
| --------------------- | ---------------- | ---------------------------------- | ------------------ |
| Azure Resource Group  | N/A              | Resource Group for Terraform state | N/A                |
| Azure Storage Account | Standard_LRS     | Storage for Terraform state        | Microsoft.Storage  |

### GitHub

| GitHub resource    | Name                           | Purpose                                             |
| ------------------ | ------------------------------ | --------------------------------------------------- |
| Team               | N/A                            | Team for team members                               |
| Repository         | N/A                            | Git repository with OpenHack files                  |
| Repository Project | N/A                            | Project for work organization                       |
| Actions Secret     | LOCATION                       | Variable with Azure location for resources          |
| Actions Secret     | TFSTATE_RESOURCES_GROUP_NAME   | Variable with Resource Group for Terraform state    |
| Actions Secret     | TFSTATE_STORAGE_ACCOUNT_NAME   | Variable with Storage Account for Terraform state   |
| Actions Secret     | TFSTATE_STORAGE_CONTAINER_NAME | Variable with Storage Container for Terraform state |
| Actions Secret     | TFSTATE_KEY                    | Variable with State Key for Terraform state         |
| Actions Secret     | AZURE_CREDENTIALS              | Variable with Azure Service Principal               |

## Deployments Steps

### Azure pre-deployment steps

Open Cloud Shell.

Go to: [shell.azure.com](https://shell.azure.com)

Login to your Azure Subscription (You can skip this step if you are using Cloud Shell for deployment).

```bash
az login
```

Make sure your login context uses the correct Azure Subscription.

```bash
az account show
```

If not, then change to your Azure Subscription dedicated for the OpenHack.

```bash
az account set --subscription <subscriptionId>
```

Verify your account permissions for the subscription. Expected value: `Owner`.

```bash
az role assignment list --assignee $(az account show --output tsv --query user.name) --output tsv --query [].roleDefinitionName --include-inherited
```

### GitHub pre-deployment steps

Login to your [GitHub](https://github.com) account and [Create a Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with scope: `repo, workflow, admin:org, admin:public_key, delete_repo, user, write:discussion, read:enterprise`.

Then set environment variable `GITHUB_TOKEN` with generated token.

```bash
export GITHUB_TOKEN="<GitHubPAT>"
```

### Deployment

Clone GitHub repo with BYOS resources.

```bash
git clone https://github.com/microsoft/OpenHack.git
```

Go to DevOps OpenHack deployments scripts.

```bash
cd OpenHack/byos/devops/deploy
```

Make deployment script executable.

```bash
chmod +x deploy-gh.sh
chmod +x semver2.sh
```

Run `deploy-gh.sh` bash script to start Azure & GitHub configuration.

> **NOTE**
>
> - When running on Windows in WSL, ensure that all \*.sh files use correct line endings (`LF`), because the default behavior when cloning files on Windows is to switch to CRLF. That can cause issues when running the deployment script (`-bash: ./deploy-gh.sh: /bin/bash^M: bad interpreter: No such file or directory`).
>
> - For Azure Location, `koreasouth`, `westindia`, `australiacentral`, `australiacentral2`, `brazilsoutheast`, `francesouth`, `germanynorth`, `swedencentral`, `swedensouth`, `uaecentral`, `centraluseuap`, `eastus2euap`, `norwaywest`, `southafricawest`, `westcentralus` are not supported!
>
> - Supported regions arguments for `AzureLocation` are:
>
> - eastus
> - eastus2
> - southcentralus
> - westus
> - westus2
> - westus3
> - australiaeast
> - southeastasia
> - northeurope
> - uksouth
> - westeurope
> - centralus
> - northcentralus
> - southafricanorth
> - centralindia
> - eastasia
> - japaneast
> - jioindiawest
> - koreacentral
> - canadacentral
> - southindia
> - francecentral
> - germanywestcentral
> - norwayeast
> - switzerlandnorth
> - uaenorth
> - brazilsouth
> - australiasoutheast
> - japanwest
> - jioindiacentral
> - outhindia
> - canadaeast
> - switzerlandwest
> - ukwest

> **IMPORTANT!** The deploy script contains optional parameters `-o <GitHubOrgName> -t <TeamName> -a <AzureDeployment>`. Please keep default parameters and do not set yours for official OpenHack events. However, you can adjust them to your needs for self-paced independent runs.

```bash
./deploy-gh.sh -l <AzureLocation>
```

> **Defaults for optional parameters**
>
> -o GitHubOrgName = DevOpsOpenHack
>
> -t TeamName = randomly generated number with 5 digits
>
> -a AzureDeployment = true (deploy Azure resources, if false, then just configure GitHub)

Example end of the output from `deploy-gh.sh` script

![End of GitHub Deployment](images/gh-deploy-end.png)

### Azure post-deployment steps

Add OpenHack team members to Azure Subscription with **Contributor** role, follow guide: [Assign Azure roles using the Azure portal
](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

### GitHub post-deployment steps

Note your Team name - you can find it under deploy script summary like `Team Name: devopsoh12345`, where **12345** is a random number.

Add OpenHack team members to GitHub Team, follow guide: [Adding organization members to a team
](https://docs.github.com/en/organizations/organizing-members-into-teams/adding-organization-members-to-a-team)

## Post-event steps

After OpenHack, clean up GitHub Organization by removing OpenHack team members from the GitHub Organization.

- **Attendees** should be removed from the GitHub organization at the end of each OpenHack by the **Coach**.
- **Coaches** should be removed from the GitHub organization after each OpenHack by the OpenHack **Tech Lead**.
- **Tech Lead** should be removed from the GitHub organization after each OpenHack by the OpenHack **Program Team**.

Follow this guide on how to do it: [Removing a member from your organization](https://docs.github.com/en/organizations/managing-membership-in-your-organization/removing-a-member-from-your-organization#revoking-the-users-membership)