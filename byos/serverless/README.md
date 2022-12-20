# OpenHack Serverless Overview

## Overview
**This OpenHack enables attendees** to quickly build and deploy Azure Serverless solutions that are comprised of cutting-edge compute services like Functions, Logic Apps, Event Grid, Service Bus, Event Hubs and Cosmos DB.   
**This OpenHack simulates a real-world scenario** where an ice cream company wants to use Platform as a Service (PaaS) to build and release an API to integrate into their distributor’s application.   
**During the “hacking” attendees will focus on:**
 1. Building serverless functions, web APIs, and CI/CD pipeline to support them
 2. Implementing Serverless technologies to integrate line-of-business app workflows, process user/data telemetry and create business KPI-aligned reports. 
 
**By the end of the OpenHack, attendees will have built out a technical solution** that is a full serverless solution that can create workflows between systems and handle events, files, and data ingestion.


## Technologies
Azure Functions, Logic Apps, Event Grid, Cosmos DB, API Management, Azure Event Hubs, Azure DevOps or GitHub (team choice), Azure Monitor, Dynamics 365/Office 365, Cognitive APIs, Service Bus

## Knowledge Prerequisites
To be successful and get the most out of this OpenHack, it is highly recommended that participants have earlier experience with API integration and a deep understanding of the language they chose to work in. Participants who are familiar with the technologies listed will be able to advance more quickly. A working knowledge of DevOps fundamentals is useful.

Required knowledge of [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/azure-fundamentals/). 

**Language-Specific Prerequisites**  
- Hands-on coding is required in at least one of the following programing languages: C#, JavaScript, Node, or Python.

**Language-Specific Prerequisites**  
- Hands-on coding is required in at least one of the following programing languages: C#, JavaScript, Node, or Python.

**Tooling Prerequisites**  
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
- A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or one of these [Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) 
- Download the latest version of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
- Your preferred IDE. If using:
- **Visual Studio for Windows**: Install [latest Visual Studio](https://visualstudio.microsoft.com/) with ‘Azure development’ workload selected and [Azure Functions and Web Jobs Tools extension ](https://docs.microsoft.com/en-us/azure/azure-functions/functions-develop-vs#check-your-tools-version)
- **Visual Studio Code in Windows, OSX, or Linux**: Install latest [Visual Studio Code](https://code.visualstudio.com/download) for your OS, [Azure Functions extension](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions), and [Azure Functions Core Tools](https://docs.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Ccsharp%2Cbash#v2)

We will do our best to place you on a team that will use the preferred language you indicated in your registration. Please identify your preferred language below and download the tools listed underneath in preparation for the OpenHack.
- C# .NET Core
    - [Visual Studio 2019](https://visualstudio.microsoft.com/) or [Visual Studio Code](https://code.visualstudio.com/download) on a [supported platform](https://code.visualstudio.com/docs/supporting/requirements#_platforms)
	Visual Studio C[ode C# Extension ](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)is recommended
    - .NET Core 2.2
- Java/Maven
    - [Java Developer Kit](https://aka.ms/azure-jdks) version 8
    - [Apache Maven](https://maven.apache.org/) version 3.0 or later
- JavaScript
    - [Visual Studio Code](https://code.visualstudio.com/download) on a supported platform
    -[ Node.js ](https://nodejs.org/en/)Active LTS and Maintenance LTS versions (8.11.1 and 10.14.1 recommended)
- Python
    - [Python 3.6.x](https://www.python.org/downloads/) (official CPython distribution)
        - 3.6.8 64-bit is recommended due to this [known issue](https://github.com/protocolbuffers/protobuf/issues/5046) 
        - Python interpreter selection can be troublesome for VS Code users on Windows
- Recommended for Mac OSX and Linux users to [install Azurite v2](https://www.nuget.org/packages/Azurite/)

**Development Environment Configuration**  
- None. 

**Links & Resources**
- [Capture and view page load times in your Azure web app with Application Insights](https://docs.microsoft.com/en-us/learn/modules/capture-page-load-times-application-insights/)
- [Architect API integration in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-api-integration/)
- [Transform data by using Azure Stream Analytics ](https://docs.microsoft.com/en-us/learn/modules/transform-data-with-azure-stream-analytics/)
- [Creating Serverless Applications](https://docs.microsoft.com/en-us/learn/paths/create-serverless-applications/)
Post Learning Recommendations
- [Automate Azure Functions deployments with Azure Pipelines](https://docs.microsoft.com/en-us/learn/modules/deploy-azure-functions/)
- [DevOps OpenHack](https://openhack.microsoft.com/)
- [Architect message brokering and serverless applications in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-messaging-serverless/)
- [Create a long-running serverless workflow with Durable Functions (module)](https://docs.microsoft.com/en-us/learn/modules/create-long-running-serverless-workflow-with-durable-functions/

## Challenge Overview
**Challenge 1: Environment Configuration**  
In this challenge, you will get your development environment ready to develop serverless applications.
Learning objectives:  
- Install the required software and pre-requisites to build and test the Azure Functions Locally

**Challenge 2: Create your first serverless function & workflow**  
In this challenge, you will create and deploy your first Azure Function and Logic App.
Learning objectives:  
- Create your first Functions Web API locally and deploy to the Azure cloud
- Get familiar with the Azure Portal to create resources required to host your APIs
- Build your first Logic Apps workflow on the portal directly  

**Challenge 3: Expand and build a full set of APIs to support business needs**  
In this challenge, you will build an API to persist and retrieve data from a data store and configure a CI/CD pipeline.
Learning objectives:  
- Gain experience building multiple Web APIs that accept and output a different type of data in JSON
- Experience the local and cloud testing of the APIs by making calls from your local machine
- Build a Continuous Deployment and Continuous Integration (CI/CD) pipeline from source control

**Challenge 4: Deploy a management layer for APIs to monitor and track your APIs**  
In this challenge, you will enable monitoring of the APIs, as well as devise an API management strategy.
Learning objectives:  
- Learn how you can capture and report telemetry about the APIs that are hosted on the cloud
- Experience building an API management layer to manage the APIs and expose it through a common base endpoint

**Challenge 5: Build a workflow process**  
In this challenge, you will build a business process workflow which integrates with a CRM system.
Learning objectives:  
- Gain experience using a graphical user interface editor to build Workflows using Logic Apps
- Experience the drag and drop connectors to bring Line of Business apps to create a flow and notify contacts via emails

**Challenge 6: Process large amount of unstructured data**
In this challenge, you will process files in a batch process and persist to a data store
Learning objectives:  
- Build solutions to process batch files coming into a storage account
- Learn how to parse the flat files and store them on a database (structured or unstructured)

**Challenge 7: Process large amount of incoming events**  
In this challenge, you will process batches of messages from Event Hub and persist in a data store. You will also extend the monitoring approach created earlier to track the number of running Azure Function instances.
Learning objectives:  
- Learn how to extend the API’s to parse the JSON sales events and store them in a backend data store
- Demonstrate how you tracked the number of instances that your Azure Functions scaled up to with App Insights

**Challenge 8: Messaging Patterns and Virtual Network Integration**  
In this challenge, you will configure a messaging solution capability of filtering messages, as well as using virtual network integration to save data to a private data store.
Learning objectives:  
- Learn how to use publisher/subscriber messaging patterns with filtering rules to enable subscribers to process specific messages
- Build a serverless solution capable of working with Azure resources which utilize virtual network access restrictions

**Challenge 9: Alerting based on user sentiments**
In this challenge, you will integrate machine learning capabilities into the current solution to detect and alert on user sentiment.
Learning objectives:  
- Leveraging sentiment analysis to assess the user sentiments based on feedback
- Review the sentiments in batch and alert the responsible contacts what sentiment score products have been receiving

**Challenge 10: Putting it all together**  
In this challenge, you will create a report which summarizes key business metrics derived from the full solution. 
Learning objectives:  
- Bring all things together and demonstrate how things flow end to end
- Report insights on how the products are behaving


## Value Proposition
- Build Azure cloud native event driven applications (mid-tier and backend) using Azure Serverless technologies 
- Increase awareness on building scalable, event-driven applications with messaging services for asynchronous communication
- Remove infrastructure related tasks and considerations from developers to focus on rapid application development
- Help make decisions on when to use and how to choose Azure Services to achieve the business outcomes 
- Learn best practices for building CI/CD for Serverless and processing events at scale


## Technical Scenarios
Building API’s with Serverless event processing, workflows and integration with different systems, streaming and analytics, VNET integration and batch processing of high column data.
- **Enterprise Integration** – bring various line of business systems and applications together to orchestrate the process without having to provision large infrastructure footprint
- **DevOps Practice** – building CI and CD for the services developed to help with best practice for source control for code management
- **Scaling & Logging** – understanding the scaling aspect of services when you have a spike in events and visualization of application insights to gather business data


# Serverless Openhack

## Setting up Permissions

Before continuing ensure you understand the permissions needed to run the OpenHack on your Azure subscription.

### **Initial Setup**

To perform the setup and deployment to prepare for the OpenHack you must be be assigned to the Owner role on the Azure subscription(s).

To validate this, navigate to the [Azure Portal](https://portal.azure.com). Click on **All Services** -> **Subscriptions** -> **Access Control (IAM)**.

Enter the email address in the **Check access** text box to view the current permissions of the user performing the setup.  

![Check access dialog](check-access.png "Check access dialog displays a textbox to enter an email address.")

### **Performing the OpenHack**

Each attendee in the OpenHack will be assigned the **Owner** role on a resource group unique to their team. This is covered later in this document in the deployment section.

## Common Azure Resources

The following is a list of common Azure resources that are deployed and utilized during the OpenHack.  

Ensure that these services are not blocked by Azure Policy.  As this is an OpenHack, the services that attendees can utilize are not limited to this list so subscriptions with a tightly controlled service catalog may run into issues if the service an attendee wishes to use is disabled via policy.  

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

> Note:  Resource Provider Registration can be found at `https://portal.azure.com/_yourtenantname_.onmicrosoft.com/resource/subscriptions/_yoursubscriptionid_/resourceproviders`

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

6. Change directory to the `serverless\deploy\` folder.  Optionally, review and/or modify the script.  

    **Optionally**: modify the script to override the read of the number of teams and/or region

    ```PowerShell
    $teamCount = Read-Host "How many teams are hacking?";
    #could be
    $teamCount = 1;
    #and 
    $region = Read-Host "What Region Resources be deployed to (i.e. centralus, southcentralus, japaneast, etc)?";
    #could be
    $region = "centralus"
    ```  

7. Run the script.

    Use the command:

    ```powershell  
    .\deployAll.ps1
    ```  

    To run the script.  

    > *Note: if you receive an error that `azuredeploy.json` cannot be found, make sure the current directory of the Console window of **Powershell** is the `serverless\deploy` folder.*  

   * Create resource group entitled **ServerlessOpenHackRGXX-[location]** where XX is the two-digit team number and location is the location you entered or have in the script.  For example, team 2 in **southcentralus** would have the expected resource group `ServerlessOpenHackRG02-southcentralus`  
   * Two Storage Accounts with respective containers [sohsalesxxxxxxxxx] and [sohvmdiagxxxxxxxxx]
   * VPN [soh-vnet]
   * Network Interface [soh-jumpbox-nic]
   * Network Security Group [soh-jumpbox-nsg]
   * Public ID [soh-jumpbox-pip]
   * VM disk [soh-jumpbox_OsDisk_1_xxxxxxxxxxxxx]
   * VM  [soh-jumpbox]

### Manual step

After deployment, manually add appropriate users with owner access on the appropriate resource group for their team, so that they will have ability to create and deploy resources in that resource group.

## Deployment Artifacts / Validation

After deployment has completed, you should see the following resources in each team's Resource Group: 

* Team XX resource group  (i.e. `ServerlessOpenHackRG01-centralus`)
* VM - [soh-jumpbox]
* NIC - [soh-jumpbox-nic]
* NSG - [soh-jumpbox-nsg]
* Public IP - [soh-jumpbox-pip]
* Disk - [soh-jumpbox_OsDisk_1_xxxxxxxx]
* VPN - [soh-vnet]
* Storage Sales [sohsalesxxxxxxxxxx]  
    - container [receipts]  
    - container [receipts-high-value]  
* Storage VMDiagnostics [sohvmdiagxxxxxxxxx]  
    - container [bootdiagnostics-sohjumpbo-(guidish)]

## More detail on the usage of the services  

As the teams progress:  

* Make sure teams can create and work with storage
* Make sure teams can create Logic Apps
* Make sure teams can create functions using standard/free function app service, and eventually updated to premium
* Make sure teams can create APIM
* Make sure teams can create Event Hubs and integrate triggers with Event Grid
* Make sure teams can create Service Bus and use for appropriate messaging
* Make sure teams can use Stream Analytics to filter information
* Make sure teams can provision cognitive services

## Services and application overview  

The following services and applications are utilized in this OpenHack.

### Logic Apps  

Notes:  

* users will make at least two, likely four or five  
* responding to events and processing to push emails against a 3rd party Outlook/Business server  
* route messages to functions or other responding events  
* aggregate data for reporting, etc.  

### Cosmos DB and/or Azure Tables  

Notes:  

* Cosmos DB will be a lot easier in the later challenges, so recommend using Cosmos DB
* They will need to be able to create tables and respond to events against Cosmos DB

### APIM

Notes:  

* participants will create an API management gateway to group internal and external APIs  
* use APIM to build various subscriptions for access

### Azure Functions

Notes:

* multiple functions will be created/deployed
* http or event grid or storage triggered, will eventually need to be able to push requests to a VPN endpoint

### App Service

Notes:  

* Leverage Azure Functions in function apps
* starts with basic/free plan
* will potentially need Premium plan for network integration to route traffic/lock down functions.

### Cognitive Services  

Notes:

* Cognitive Services to parse intent on messages/reviews  
* using Text Analytics API, integrated with events and queues  

### Messaging and Events

Notes:  

* Event Grid/Event Hub for message processing  
* Service Bus for message queueing  

### Storage  

Notes:

* public blob with container to receive hundreds of csv files that will be pushed to the storage by third party app
* ability to respond to storage creation events via Logic App or Azure Function

### IaaS  

Notes:  

* Networking  
* teams will need build something that pushes to a third-party VPN

* VM
* a jump-box VM is created for teams to view VPN endpoints from third-party service.

### Stream Analytics  

Notes:  

* Used To aggregate data for reporting  

### Deployment/Pipelines/Source Repository  

Teams will need to setup CI/CD pipelines in Azure DevOps or GitHub

### Development Tools  

Need to use one or more of the following to complete the work

* Visual Studio - teams will need to be able to write code in Visual Studio
* Java / Maven  
* VS Code / Python & node/other development
* Postman
