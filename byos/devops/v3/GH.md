# DevOps OpenHack Deployment for GitHub

## Prerequisites

- [Azure Subscription](https://azure.microsoft.com/) with [Owner](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles) role
- [GitHub Organization](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/about-organizations) within [GitHub Enterprise Cloud](https://docs.github.com/en/get-started/learning-about-github/githubs-products#github-enterprise) with [GitHub Advanced Security](https://docs.github.com/en/get-started/learning-about-github/about-github-advanced-security)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux)
- [Python 3.x](https://www.python.org/downloads/)
- [jq](https://stedolan.github.io/jq/download/)

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

Create a new Service Principal with **Owner** role dedicated only for the OpenHack, and save the result to `azuresp.json` file. Make sure the `azuresp.json` is in teh same place where `deploy-gh.sh` script.

```bash
az ad sp create-for-rbac --sdk-auth --role Owner > azuresp.json
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
