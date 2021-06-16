# Application Modernization with NoSQL OpenHack

## Permissions  

## Setting up Permissions

Before continuing ensure you understand the permissions needed to run the OpenHack on your Azure subscription.

### **Initial Setup**

To perform the setup and deployment to prepare for the OpenHack you must be be assigned to the Owner role on the Azure subscription(s).

To validate this, navigate to the [Azure Portal](https://portal.azure.com). Click on **All Services** -> **Subscriptions** -> **Access Control (IAM)**.

Enter the email address in the **Check access** text box to view the current permissions of the user performing the setup.  

![Check access dialog](images/check-access.png "Check access dialog displays a textbox to enter an email address.")

### **Performing the OpenHack**

Each attendee in the OpenHack will be assigned the **Owner** role on a resource group unique to their team. This is covered later in this document in the deployment section.

## Common Azure Resources

The following is a list of common Azure resources that are deployed and utilized during the OpenHack.  

Ensure that these services are not blocked by Azure Policy.  

As this is an OpenHack, the services that attendees can utilize are not limited to this list so subscriptions with a tightly controlled service catalog may run into issues if the service an attendee wishes to use is disabled via policy.  

| Azure resource           | Resource Providers |  
| ------------------------ | --------------------------------------- |  
| Azure Cognitive Services | Microsoft.CognitiveServices             |  
| Azure Cognitive Search   | Microsoft.Search                        |  
| Azure Functions          | Microsoft.Web                           |  
| Azure App Service        | Microsoft.Web                           |  
| Azure Logic Apps         | Microsoft.Logic                         |  
| Azure Storage            | Microsoft.Storage                       |  
| Azure Machine Learning   | Microsoft.MachineLearningServices       |  
| Azure Cosmos Db          | Microsoft.DocumentDb                    |  
| Data Factory             | Microsoft.DataFactory                   |  
| Event Hub                | Microsoft.EventHub                      |  
| Event Grid               | Microsoft.EventGrid                     |  
| Azure Cache for Redis    | Microsoft.Cache                         |  
| Power BI                 | Microsoft.PowerBI                       |  
| HDInsight                | Microsoft.HDInsight                     |  
| Azure Databricks         | Microsoft.Databricks                    |  
| Azure Stream Analytics   | Microsoft.StreamAnalytics               |  

>**Note:**  Resource Provider Registration can be found at `https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders`  

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the OpenHack on. Ensure they have adequate permissions to perform software installation.  

## Deployment Instructions  

For deployment, you will run a PowerShell script that executes an ARM template to setup the appropriate Resource Group for each team.  You will then manually add team members as owners to the resource group. You may run the script in **PowerShell 7+** or in the **PowerShell ISE**, whichever you prefer.

### PowerShell  

1. Open a **PowerShell 7** window, run the following command, if prompted, click **Yes to All**:

   ```PowerShell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

2. Make sure you have the latest PowerShell Azure module installed by executing the following command:

    ```PowerShell
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    ```

3. If you installed an update, **close** the PowerShell 7 window, then **re-open** it. This ensures that the latest version of the **AZ** module is used.

4. Execute the following to sign in to the Azure account:

    ```PowerShell
    Connect-AzAccount
    ```  

5. If you have more than one subscription, be sure to select the right subscription before the next step. Use `Get-AzSubscription` to list your subscriptions and then use the `Select-AzSubscription` command as shown below to set the subscription you're targeting for the deployment:

    List subscriptions:  

    ```powershell
    Get-AzSubscription
    ```  

    Select the subscription to use:

    ```powershell
    Select-AzSubscription -Subscription <The selected Subscription Id>
    ```  

6. At the command prompt, navigate to the `..\deploy` directory, which contains the `deployAll.ps1` script with typical commands such as  

    ```powershell  
    cd C:\the-root-path\...\byos\app-modernization-no-sql\deploy
    ```  

    ![Get to the correct directory](images/image0001.png "Get to the correct directory.")  

7. Run the script `deployAll.ps1`  

    You will only need to input the number of teams and the two regions you want to deploy to and the script. 
    
    >**Optionally:** if desired, you could modify the script before running it to set a different admin username and password than the defaults listed in the script.  

    ![Deploying the open hack using powershell](images/image0005.png "When the script runs you need to input the number of teams and the two locations")  

    >**Note:** The script will take some time to run, and if you have more than one team it will have to run multiple iterations.  If you are re-deploying, you will be prompted to replace existing resource groups.  This takes a bit longer.  

    If the database import does not run synchronously, you will get an error on the final validation.  At this point, all resources are deployed, you just don't have data, so even though the deployment failed, you would just need to use script 3 to import the data and script 4 to then validate it worked (or just look at the website on the publicly exposed url).  

    ![The output](images/image0006.png "The final output of the script is shown in this image")  

## Deployment artifacts / Validation

After deployment has completed, you should see the following resources:

### Resource group 1 ("nosql-XX-openhack1") where XX is the team number (i.e. "nosql-03-openhack1")

The following resources are deployed to the first resource group:

* Event Hubs Namespace with an event hub named `telemetry`
* SQL Server with firewall settings set to allow all Azure services and IP addresses from 0.0.0.0 - 255.255.255.255
* Azure SQL Database named `Movies`
* App Service containing the deployed web app with a SQL connection string added to the Configuration settings

### Resource group 2 ("nosql-XX-openhack2") (i.e. "nosql-03-openhack2")

The following resources are deployed to the second resource group:

* Event Hubs Namespace with an event hub named `telemetry`

### Additional resources

In addition to the deployed resources, this OpenHack uses additional resources, as listed below:

* DataGenerator.zip

    * [Download the zip file](https://openhackguides.blob.core.windows.net/no-sql-artifacts/DataGenerator.zip) for the data generator used in the OpenHack.  

## Common Resources and Quotas needed

Resources users will create/provision/interact with:

### CosmosDb

* Regular or Mongo recommended, others available but not as easy

### Azure Data Factory

* Migration of data needs to be repeatable and needs to denormalize the data

### Event Hub

### Spark/Databricks/HDInsight/Stream Analytics

### Redis Cache

### Power BI  

* Dashboard reporting

### Azure Functions

### Azure App Service for Function App

### Azure Logic Apps

### Azure Cognitive Search / Elastic Search
