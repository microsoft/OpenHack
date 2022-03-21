
# Modern Data Warehouse OpenHack

## Setting up Permissions  

Before continuing ensure you understand the permissions needed to run the OpenHack on your Azure subscription.

Attendees should have Azure subscription permissions which allow the creation of resources in their resource group. Additionally, attendees should have sufficient subscription permissions to create service principals in Azure AD and to register applications in Azure AD. Typically, all that is required is a user account with `Owner` role on their resource group.

## Common Azure Resources

The following is a list of common Azure resources that are deployed and utilized during the OpenHack. 

Ensure that these services are not blocked by Azure Policy. As this is an OpenHack, the services that attendees can utilize are not limited to this list so subscriptions with a tightly controlled service catalog may run into issues if the service an attendee wishes to use is disabled via policy.

| Azure resource           | Resource Providers |
| ------------------------ | --------------------------------------- |
| Azure Cosmos DB          | Microsoft.DocumentDB                    | 
| Azure Data Factory       | Microsoft.DataFactory                   |
| Azure Purview            | Microsoft.Purview                       |
| Azure Synapse            | Microsoft.Synapse                       |
| Azure Databricks         | Microsoft.Databricks                    |
| Azure SQL Database       | Microsoft.SQL                           |
| Azure Storage            | Microsoft.Storage                       |
| Azure Data Lake Store    | Microsoft.DataLakeStore                 |
| Azure Virtual Machines   | Microsoft.Compute                       |

> Note:  Resource Provider Registration can be found at https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the OpenHack on. Ensure they have adequate permissions to perform software installation.

## Deployment Instructions  

1. Open a **PowerShell 7** window, run the following command, if prompted, click **Yes to All**:

   ```PowerShell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

2. Execute the following to sign in to the Azure account that has the **Owner** role assignment in your subscription.

    ```PowerShell
    Connect-AzAccount
    ```

3. If you have more than one subscription, be sure to select the right one before the next step. Use `Get-AzSubscription` to list them and then use the command below to set the subscription you're using:

    List subscriptions:  

    ```powershell
    Get-AzSubscription
    ```  

    Select the subscription to use:

    ```powershell
    Select-AzSubscription -Subscription <The selected Subscription Id>
    ```

4. Assign the `$sqlpwd` and `$vmpwd` variables in your PowerShell session as **Secure Strings**. Be sure to use a strong password for both. Follow [this link](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm) for Virtual Machine password requirements and [this link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-2017#password-complexity) for SQL Server.

    ```powershell
    $PlainPassword = "demo@pass123"
    $SqlAdminLoginPassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    $VMAdminPassword = $PlainPassword | ConvertTo-SecureString -AsPlainText -Force
    ```  

5. If you have not already done so, you will need to download the `modern-data-warehousing` folder from the repository.  You can use the following command to clone the repo to the current directory:

   ```shell
   git clone https://github.com/microsoft/OpenHack.git
   ```
  
6. Execute the following from the `modern-data-warehousing` directory of the OpenHack repository clone to deploy the environment (this process may take 10-15 minutes):

    ```powershell
     .\BYOS-deployAll.ps1 -SqlAdminLoginPassword $SqlAdminLoginPassword -VMAdminPassword $VMAdminPassword 
    ```

### Manual step - Assigning Users to Each Resource Group  

After deployment, manually add the appropriate users with owner access on the appropriate resource group for their team.  

See the following for detailed instructions for assigning users to roles.

[Add or remove Azure role assignments using the Azure portal](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal)

## Validate  

Resource Groups exist for each of the teams, members are in each team appropriately with owner permission on the resource group.

Review the readme file for Prerequisites/other things to check for each team.

## More details on the usage of the services

When you kick off the process, a number of templates are deployed.

### DeployMDWOpenHackLab.json

You kicked this off (likely from the BYOS-deployAll.ps1 script).  

This deployment template triggers the orchestrator template with the same name that is in Azure storage.  

#### Parameters

Note that using the `DeployMDWOpenHackLab.parameters.json` will supply most of these parameters for you. The ones which need attention at deployment time have been marked in **bold** below.

- SqlAdminLogin: The SQL administrator username for **all** SQL DBs in this deployment.
- **SqlAdminLoginPassword**: The password for the SqlAdminLogin on **all** SQL DBs in this deployment.
- SalesDacPacPath: URI to the bacpac imported into the CloudSales (southridge) DB.
- StreamingDacPacPath: URI to the bacpac imported into the CloudStreaming (southridge) DB.
- VMAdminUsername: The administrator username for **all** VMs in this deployment
- **VMAdminPassword**: The password the for administrator on **all** VMs in this deployment
- RentalsBackupStorageAccountName: The storage account in which dbbackups are stored
- RentalsBackupFileName: The filename for the .bak imported into the "on-premises" VM's Rentals DB (VanArsdel Ltd.)
- RentalsDatabaseName: The name of the "on-premises" database restored into the VM
- RentalsCsvFolderName: The name of the folder containing all the of the CSV data, within the dbbackups container
- CatalogJsonFileName: The name of the JSON file containing all of Southridge Video's movie catalog
- SQLFictitiousCompanyNamePrefix: The fictitious company name using the "on-premises" SQL VM (VanArsdel Ltd.)
- CsvFictitiousCompanyNamePrefix: The fictitious company name using the "on-premises" CSV files (Fourth Coffee)
- CloudFictitiousCompanyNamePrefix: The fictitious company name using the cloud DBs (Southridge)
- **location**: The target Azure region

> Note: You can run the script without any parameters, as all scripts are set with default values for the critical pieces of the deployment.  Using parameters allows you to override should the need arise (such as the password).  

### DeployCosmosDB.json

Template scoped to the provisioning of a Cosmos DB account.

> The Cosmos DB collection is created and populated by a VM extension in DeployFileVM.

#### Parameters  

- location: The target Azure region
- namePrefix: The Cosmos DB account will be created with a name following the form `{namePrefix}-catalog-{uniqueStringForResourceGroup}`

### DeployFileVM.json

Template scoped to the creation of the VM where one fictitious company stores their CSV data.

> This VM deployment contains the extension which not only downloads the CSV data to the VM, but also populates the Cosmos DB movie catalog.

#### Parameters

- adminUsername: VM admin username
- adminPassword: VM admin password
- BackupStorageAccountName: The storage account containing the CSV data
- BackupStorageContainerName: The container within the storage account which contains the CSV data
- RentalsCsvFolderName: The folder within the container which contains the CSV data
- catalogJsonFileName: The filename of the southridge movie catalog to upload into Cosmos
- location: The target Azure region
- namePrefix: The VM resources will use this name, e.g., `{namePrefix}VM`, `{namePrefix}-PIP`, etc.

### DeploySQLAzure.json

This template deploys two Azure SQL DBs into a single server, and performs a bacpac import for each.

#### Parameters

- AdminLogin: The SQL admin login
- AdminLoginPassword: The SQL admin password
- SalesDacPacPath: The path to the CloudSales bacpac
- StreamingDacPacPath: The path to the CloudStreaming bacpac
- DacPacContainerSAS: The SAS for the dbbackups container
- location: The target Azure region
- namePrefix: The SQL server name will be formatted as `{namePrefix-sqlserver-uniqueStringForResourceGroup}`

### DeploySQLVM.json

This deploys a VM with SQL server, and imports a bak for the on-premises rentals DB.

#### Parameters

- adminUsername: VM admin username
- adminPassword: VM admin password
- sqlAuthenticationLogin: SQL username
- sqlAuthenticationPassword: SQL password
- BackupStorageAccountName: The storage account containing the bak
- BackupStorageContainerName: The container within the storage account which contains the bak
- BackupFileName: The bak filename
- DatabaseName: The name of the restored DB
- location: The target Azure region
- namePrefix: The VM resources will use this name, e.g., `{namePrefix}VM`, `{namePrefix}-PIP`, etc.
