# Serverless Openhack #

## Setting up Permissions 

Before continuing ensure you understand the permissions needed to run the OpenHack on your Azure subscription.

**Initial Setup** 

To perform the setup and deployment to prepare for the OpenHack you must be be assigned to the Owner role on the Azure subscription(s).

To validate this, navigate to the <a href="https://portal.azure.com" target="_blank">Azure Portal</a>. Click on **All Services** -> **Subscriptions** -> **Access Control (IAM)**.

Enter the email address in the **Check access** text box to view the current permissions of the user performing the setup.  

![Check access dialog](images/check-access.png "Check access dialog displays a textbox to enter an email address.")

**Performing the OpenHack** 

Each attendee in the OpenHack will be assigned the **Owner** role on a resource group unique to their team. This is covered later in this document in the deployment section.


## Common Azure Resources 

The following is a list of common Azure resources that are deployed and utilized during the OpenHack. 
Ensure that these services are not blocked by Azure Policy.  As this is an OpenHack, the services that attendees can utilize are not limited to this list so subscriptins with a tightly controlled service catalog may run into issues if the service an attendee wishes to use is disabled via policy.


| Azure resource           | Resource Providers |
| ------------------------ | --------------------------------------- | 
| Azure Logic Apps         | Microsoft.Logic                         |
| Azure Functions          | Microsoft.Web                           |
| Azure App Service        | Microsoft.Web                           |
| Azure Storage            | Microsoft.Storage                       |
| Azure Cosmos DB          | Microsoft.DocumentDb                    |
| Event Hub                | Microsoft.EventHub                      |
| Event Grid               | Microsoft.EventGrid                     |
| Azure Cognitive Services | Microsoft.CognitiveServices             |
| Virtual Network          | Microsoft.Network                       |
| Azure Stream Analytics   | Microsoft.StreamAnalytics               |
| Virtual Machine          | Microsoft.VMWare                        |
| Azure DevOps             | Microsoft.VSOnline                      |
| Service Bus              | Microsoft.ServiceBus                    |

> Note:  Resource Provider Registration can be found at https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the OpenHack on. Ensure they have adequate permissions to perform software installation. 


# Deployment Instructions #  

### For deployment, you will run a powershell script that executes an ARM template to setup the appropriate Resource Group for each team.  You will then manually add team members as owwers to the resource group. ###

### Powershell ###
1. Open a **PowerShell ISE** window, run the following command, if prompted, click **Yes to All**:

   ```PowerShell
   Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
   ```

2. Make sure you have the latest PowerShell Azure module installed by executing the following command:

    ```PowerShell
    Install-Module -Name Az -AllowClobber -Scope CurrentUser
    ```

3. If you installed an update, **close** the PowerShell ISE window, then **re-open** it. This ensures that the latest version of the Az module is used.

4. Execute the following to sign in to the Azure account:

    ```PowerShell
    Connect-AzAccount
    ```

5. Open the `serverless-deployment\deployAll.ps1` PowerShell script in the PowerShell ISE window.  There is **nothing** to update, but if you wanted you ***could*** set the location and not require the read-in from the prompt.:

    ```PowerShell
    $region = Read-Host "What Region Resources be deployed to (i.e. centralus, southcentralus, japaneast, etc)?";
    #could be
    $region = "centralus"
    ```

6.  Press **F5** to run the script, this will do the following:

   * Create resource group entitled **ServerlessOpenHackRGXX-[location]** where XX is the two-digit team number and location is the location you entered or have in the script.  For example, team 2 in southcentralus would have rg ServerlessOpenHackRG02-southcentralus
   * Deploy two storage accounts with containers [sohsalesxxxxxxxxx] and [sohvmdiagxxxxxxxxx]
   * Deploy a VPN [soh-vnet]
   * Deploy a Network Interface [soh-jumpbox-nic]
   * Deploy a Network Security Group [soh-jumpbox-nsg]
   * Deploy a public ID [soh-jumpbox-pip]
   * Deoply a VM dis [soh-jumpbox_OsDisk_1_xxxxxxxxxxxxx]
   * Deploy a VM  [soh-jumpbox]

### Manual step ### 

7. After deployment, manually add appropriate users with owner access on the appropriate resource group for their team, so that they will have ability to create and deploy resources in that resource group.

# Deployment Artifacts / Validation #

### After deployment has completed, you should see the following resources in each team's Resource Group: ###

* Team XX resource group  (i.e. ServerlessOpenHackRG01-centralus)

  * VM - [soh-jumpbox]
  * NIC - [soh-jumpbox-nic]
  * NSG - [soh-jumpbox-nsg]
  * Public IP - [soh-jumpbox-pip]
  * Disk - [soh-jumpbox_OsDisk_1_xxxxxxxx]
  * VPN - [soh-vnet]
  * Storage Sales [sohsalesxxxxxxxxxx]
  * Storage VMDiagnostics [sohvmdiagxxxxxxxxx]
 
### More detail on the usage of the services ###
## As the teams progress: ##  
 
* Make sure teams can create and work with storage
* Make sure teams can create Logic Apps
* Make sure teams can create functions using standard/free function app service, and eventually updated to premium
* Make sure teams can create APIM
* Make sure teams can create Event Hubs and integrate triggers with Event Grid
* Make sure teams can create Service Bus and use for appropriate messaging
* Make sure teams can use Stream Analytics to filter information
* Make sure teams can provision cognitive services

## Services and application overview ##
* Logic Apps 
    * users will make at least two, likely four or five 
    * responding to events and processing to push emails against a 3rd party Outlook/Business server
    * route messages to functions or other responding events
    * aggregate data for reporting, etc.

* Cosmos Db and/or Azure Tables 
    * CosmosDb will be a lot easier in the later challenges, so recommend using CosmosDb
    * They will need to be able to create tables and respond to events against Cosmosdb

* APIM 
    * participants will create an API management gateway to group internal and external apis 
    * use APIM to build various subscriptions for access

* Azure Functions 
    * multiple functions will be created/deployed
    * http or event grid or storage triggered, will eventually need to be able to push requests to a VPN endpoint

* App Service 
    * for azure functions 
    * starts with basic/free plan
    * will eventually need Premium plan for network integration to route traffic/lock down functions.

* Cognitive Services to parse intent on messages/reviews 
    * using Text Analytics API, integrated with events and queues

* Event Grid/Event Hub for message processing

* Service Bus for message queueing

* Azure Storage 
    * public blob with container to receive hundreds of csv files that will be pushed to the storage by third party app
    * ability to respond to storage creation events via Logic App or Azure Function

* Networking 
    * teams will need build something that pushes to a third-party VPN

* VM
    * a Jumpbox VM is created for teams to view VPN endpoints from third-party service.

* Stream Analytics 
    * To aggregate data for reporting, 

## Other tools/resources: ##

* DevOps 
    * teams will need to setup a CI/CD pipeline, recommened use of DevOps to deploy functions to to Azure
OR
* GitHub
    * use a github pipeline to deploy to azure

* One or more of the following:
    * Visual Studio - teams will need to be able to write code in Visual Studio
    * Java / Maven 
    * VS Code / Python & node/other development

* Postman
