# Deployment Guide
This deployment guide will assist you in deploying the required resources and artifacts for the Microsoft Azure Well-Architected OpenHack.

> Total deployment time may take **15-20 minutes** for provisioning Azure resources.

## Prerequisites
* Azure DevOps Organization/Tenant (the script will create the necessary projects and upload the artifacts)
* Azure subscription
* [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
* [Bicep Azure CLI extension](https://github.com/Azure/bicep/blob/main/docs/installing.md#install-the-bicep-cli-details)
* [.NET 5.0 Runtime](https://dotnet.microsoft.com/download/dotnet/5.0)
* [Git CLI](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

## Deployment
The deployment script **requires** the following five parameters.  
| Flag | Description | Help |
| ---- | ----------- | ---- |
| `-p` | A personal access token for Azure DevOps |  [Create a PAT](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page#create-a-pat) |
| `-a` | The path to the Azure AUTH file. | [Using an authentication file](https://github.com/Azure/azure-libraries-for-net/blob/master/AUTH.md#using-an-authentication-file) |
| `-o` | The name of the Azure DevOps organization. | |
| `-s` | The path of the parent source folder. The source folder is the parent folder containing the `bicep` and `portal` folders.| |
| `-u` | The Azure subscription Id. | |


### Steps:
1. If necessary, create a target Azure DevOps organization
2. Retrieve your Azure DevOps PAT (see above)
3. If necessary, create a target Azure subscription
4. Generate an Azure AUTH file (see above)
5. Run the command below

Assuming you are currently in the `/deploy` folder:  

**bash**
```bash
chmod 755 ./deploy.sh
./deploy.sh -p [pat] -o [organization] -s ../source -a [auth.file] -u [subscriptionId]
```

**command prompt**
```bash
deploy -p [pat] -o [organization] -s ..\source -a [auth.file] -u [subscriptionId]
```

>NOTE: Generating the ARM template from the Bicep definition files will generate some warnings. This is expected and due to the Azure REST API not being updated.
## Process
The deployment application follows the below execution plan.

1. Deploys the Azure DevOps artifacts
   1. Creates the `Bicep` project in Azure DevOps
   2. Creates a `bicep` repository
   3. Commits Bicep artifacts to repository
   4. Creates the  'Portal` project in Azure DevOps
   5. Creates a `processor` repository
   6. Commits Processor source files to repository
   7. Creates a `web` repository
   8. Commits Web (UI and API) source files to repository
2. Deploys the initial Azure resources
   1. Builds the ARM template from the Bicep definition
   2. Creates a resource group
   3. Deploys the ARM template to the Azure subscription