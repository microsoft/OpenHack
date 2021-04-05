# IOT Gateway Operations Openhack #

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

Ensure that these services are not blocked by Azure Policy.  As this is an OpenHack, the services that attendees can utilize are not limited to this list so subscriptions with a tightly controlled service catalog may run into issues if the service an attendee wishes to use is disabled via policy.  


| Azure resource              | Resource Providers |
| --------------------------- | -------------------------------------- | 
| Azure Resources             | Microsoft.Resources                    |
| Azure Storage               | Microsoft.Storage                      |
| IoT Hub                     | Microsoft.Devices/IoTHubs              |
| Virtual Machines            | Microsoft.Compute                      |
| Device Provisioning Service | Microsoft.Devices                      |
| Azure Security/IoT          | Microsoft.Security                     |
| Azure DevOps                | Microsoft.DevOps                       |
| Virtual Network             | Microsoft.Network                      |
| Azure Stream Analytics      | Microsoft.StreamAnalytics              |
| Virtual Machine             | Microsoft.VMWare                       |
| Azure DevOps                | Microsoft.VSOnline                     |
| Azure Container Registry    | Microsoft.ContainerRegistry            |
| Azure Monitoring            | Microsoft.AlertsManagement             |
|                             | Microsoft.Insights                     |
|                             | Microsoft.OperationalInsights          |
|                             | Microsoft.Portal/dashboards/           |
| Azure Time Series Insights  | Microsoft.TimeSeriesInsights           |
| Power BI                    | Microsoft.PowerBI                      |
| Service Bus                 | Microsoft.ServiceBus                   |
| * Azure Logic Apps          | Microsoft.Logic                        |
| * Azure Functions           | Microsoft.Web                          |  

>**Note:**  [Mapping Resource Providers by resource can be found here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers)  

>**Note:**  [Resource Provider Registration can be found here](https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders)  

>**Note:** The `*` indicates optional paths for processing that are not required, but might be leveraged by some teams

## Attendee Computers

Attendees will be required to install software on the workstations that they are performing the OpenHack on. Ensure they have adequate permissions to perform software installation. 

In lieu of developer machines, a low-cost azure virtual machine could be used for development.

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

5. Open the `iot-gatewayoperations\deploy\deployAll.ps1` PowerShell script in the PowerShell ISE window.  There is **nothing** to update, but if you wanted you ***could*** set the location and not require the read-in from the prompt.:

    ```PowerShell
    $region = Read-Host "What Region Resources be deployed to (i.e. centralus, southcentralus, japaneast, etc)?";
    #could be
    $region = "centralus"
    ```

6.  Press **F5** to run the script, this will do the following:
> *Note: if you receive an error that `azuredeploy.json` cannot be found, make sure the current directory of the Console window of **ISE** is the `iot-gatewayoperations\deploy` folder.*  

   * Create resource group entitled **IoTGatewayOpsOpenHackRGXX-[location]** where XX is the two-digit team number and location is the location you entered or have in the script.  For example, team 2 in eastus would have RG set to `IoTGatewayOpsOpenHackRG02-eastus`.  

### Manual step ### 

7. After deployment, manually add appropriate users with owner access on the appropriate resource group for their team, so that they will have ability to create and deploy resources in that resource group.

# Deployment Artifacts / Validation #

### After deployment has completed, you should see the following resources in each team's Resource Group: ###

* Team XX resource group  (i.e. `IoTGatewayOpsOpenHackRG02-eastus`)
 
### More detail on the usage of the services ###
## As the teams progress: ##  
 
* Make sure teams can create and work with storage
* Make sure teams can create an IoT Hub and a Device Provisioning Service
* Make sure teams can create a Linux-based VM.
* Make sure teams can create Service Bus and use for appropriate messaging
* Make sure teams can use Stream Analytics to filter information
* Make sure teams can leverage a dashboard solution
* Make sure teams can create time series insights
* Make sure teams can leverage Azure DevOps

## Services and application overview ##
* Virtual Machine 
    * users will provision a single VM that is linux-based
    * users will leverage VSCode or another tool to SSH to the box

* IoT Hub
    * Users will need to provision an IoT Hub and be able to manage it.
    * Users should be able to turn on IoT Defender
    * Users will need to provision up to 1000 IoT Edge devices

* Device Provisioning Service
    * Users will need to be able to provision a DPS
    * Users will need to create an enrollment group
    * Users will need to provision up to 1000 IoT Edge devices

* Azure Container Registry 
    * Pipeline deploys simulator to ACR

* Azure DevOps 
    * Pipelines to build the simulator
    * Pipelines to deploy the simulator to all edge devices

* Azure Dashboard
    * Create a view that shows IoT Metrics
    * Metrics collection assets are in place

* Azure Stream Analytics
    * Ability to filter and query against device metrics
    * Input and Output make sense
    * Leverage Edge Deployments

* Service Bus for message queueing
    * One of the final requirements is ordered processing

* Azure Storage 
    * Storage of metric data for cold path analysis
    * Additional Storage duties

* Power BI (or another tool)
    * Users will want to create a visualization

* Time Series Insights
    * Users will need to leverage TSI as part of the solution

## Other tools/resources: ##

* DevOps 
    * teams will need to setup a CI/CD pipeline, recommend use of DevOps to deploy container(s) to to Azure Container Registry
OR
* GitHub
    * use a github pipeline to deploy to azure

* Developer tools for building the simulator:  

    * VS Code / Python & node/other development  
    * Visual Studio - teams will need to be able to write code in Visual Studio  
    * Java / Maven  

* SSH tool (VSCode/Putty/etc)
