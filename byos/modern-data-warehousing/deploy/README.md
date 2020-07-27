# Modern Data Warehousing OpenHack Lab Deployment

## Overview

The deployment of the Modern Data Warehousing OpenHack Lab environment includes the following

### Southridge Video Resources

- Two Azure SQL DBs in a single logical server
- A Cosmos DB account with a single collection for the movie catalog

### Fourth Coffee Resources

- A VM with a directory of CSV data

### VanArsdel, Ltd. Resources

- A VM with a SQL DB

## Quickstart

1. Assign the `$resourceGroupName` variable to a Resource Group in the target subscription.
1. Assign the `$sqlpwd` and `$vmpwd` variables in your PowerShell session as **Secure Strings**. Be sure to use a strong password for both. Follow [this link](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/faq#what-are-the-password-requirements-when-creating-a-vm) for Virtual Machine password requirements and [this link](https://docs.microsoft.com/en-us/sql/relational-databases/security/password-policy?view=sql-server-2017#password-complexity) for SQL Server.

    ```powershell
    $sqlpwd = "ThePasswordYouWantToUseForSQL" | ConvertTo-SecureString -AsPlainText -Force
    $vmpwd = "ThePasswordYouWantToUseForTheVM" | ConvertTo-SecureString -AsPlainText -Force
    ```

1. Assign the `$containerSAS` variable in your PowerShell session also as a **Secure String**. This is a rwl SAS scoped to the dbbackups container. The SAS will be provided to you outside of these instructions (in many cases, as a file called lab_backup_sas.txt):

    ```powershell
    $containerSAS = "TheContainerSASYouHave" | ConvertTo-SecureString -AsPlainText -Force
    ```

1. Use [Az Module](https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az?view=azps-1.8.0) to [Connect-AzAccount](https://docs.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-1.8.0).
1. If you have more than one subscription, be sure to select the right one before the next step. Use `Get-AzSubscription` to list them and then use the command below to set the subscription you're using:

    ```powershell
    Select-AzSubscription -Subscription <The selected Subscription Id>
    ```

1. If you still don't have the Resource Group created in the target subscription, run the following:

    ```powershell
    New-AzResourceGroup -Name $resourceGroupName -Location eastus
    ```

1. Execute the following to deploy the environment (this process may take 10-15 minutes):

    ```powershell
    New-AzResourceGroupDeployment `
        -Name full-lab-deployment `
        -ResourceGroupName $resourceGroupName `
        -TemplateFile .\DeployMDWOpenHackLab.json `
        -TemplateParameterFile .\DeployMDWOpenHackLab.parameters.json `
        -SqlAdminLoginPassword $sqlpwd `
        -VMAdminPassword $vmpwd `
        -BackupStorageContainerSAS $containerSAS
    ```

## Templates

### DeployMDWOpenHackLab.json

This deployment template links each of the others. The only dependency between the linked templates is that the DeployFileVM.json template depends on DeployCosmosDB.json; the File VM's extension populates the Cosmos DB.

#### Parameters

Note that using the `DeployMDWOpenHackLab.parameters.json` will supply most of these parameters for you. The ones which need attention at deployment time have been marked in **bold** below.

- SqlAdminLogin: The SQL administrator username for **all** SQL DBs in this deployment.
- **SqlAdminLoginPassword**: The password for the SqlAdminLogin on **all** SQL DBs in this deployment.
- SalesDacPacPath: URI to the bacpac imported into the CloudSales (southridge) DB.
- StreamingDacPacPath: URI to the bacpac imported into the CloudStreaming (southridge) DB.
- **BackupStorageContainerSAS**: SAS for the dbbackups container
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

> If you are deploying the full lab, you can stop reading now. The remainder of this document describes the linked templates in more detail, for the sake of completeness. Using the full lab template described above, all relevant parameters will be passed through to the linked templates.

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
- BackupStorageContainerSAS: The SAS for the  backup container
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
- BackupStorageContainerSAS: The SAS for the  backup container
- BackupFileName: The bak filename
- DatabaseName: The name of the restored DB
- location: The target Azure region
- namePrefix: The VM resources will use this name, e.g., `{namePrefix}VM`, `{namePrefix}-PIP`, etc.
