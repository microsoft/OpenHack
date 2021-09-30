# DevOps OpenHack Deployment for GitHub

## Prerequisites

- [Azure Subscription](https://azure.microsoft.com/) with [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role
- [GitHub Organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/about-organizations) within [GitHub Enterprise Cloud](https://docs.github.com/en/get-started/learning-about-github/githubs-products#github-enterprise) with [GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- Linux Bash ([Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/en-us/windows/wsl/) works too)
- [Azure CLI 2.28.x](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux) or higher
- [Python 3.8.x](https://www.python.org/downloads/) or higher
- [jq 1.5](https://stedolan.github.io/jq/download/) or higher

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

### GitHub pre-deployment steps

Login to your [GitHub](https://github.com) account and [Create a Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with scope: `repo, workflow, admin:org, read:enterprise`. Then set environment variable `GITHUB_TOKEN` with generated token.

```bash
export GITHUB_TOKEN="<GitHubPAT>"
```

### Deployment

Run `deploy-gh.sh` bash script to start Azure & GitHub configuration

```bash
./deploy-gh.sh -l <AzureLocation>
```

### Azure post-deployment steps

Add OpenHack team members to Azure Subscription with **Contributor** role, follow guide: [Assign Azure roles using the Azure portal
](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

### GitHub post-deployment steps

Add OpenHack team members to GitHub Team, follow guide: [Adding organization members to a team
](https://docs.github.com/en/organizations/organizing-members-into-teams/adding-organization-members-to-a-team)

## Expected resources

### azuresp.json

The `deploy-gh.sh` script creates `azuresp.json` file with Service Principal credentials. Service Principal has **Owner** role and it's dedicated for the OpenHack.

### Azure

TODO

### GitHub

TODO
