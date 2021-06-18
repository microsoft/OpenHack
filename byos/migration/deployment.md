# LOB Migration Open Hack

This document contains information and instructions for deploying the Migration Open Hack into your own Azure subscription.  

## Azure AD Guidance

In this OpenHack, you will perform tasks that require Global Admin/Company Administrator and Owner permissions on your Azure Subscription.

>**Note**: You will not be able to run this on an AzurePass as you will need to deploy 16 cores, and this will exceed the limit of an AzurePass subscription.

## Azure AD

In order to complete this OpenHack, you will need to do the following:

* [Create a new Tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant)  

* [Assocate tenant to an existing subscription](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-subscriptions-associated-directory)  

Therefore, you must have the ability to create a tenant and assign the tenant to your subscription of choice.  

## Environment Deployment

To deploy the environment for this OpenHack, you will need to execute an Azure Resource Manager template to execute two linked ARM templates.  

Execute the following steps to deploy the templates:

1) Create a resource group called `openhackonpremrg` in a region with support for Standard\_D16s\_v3 virtual machines.  

2) Use the following link to deploy the templates:  



- azuredeployOnPrem.json



-   This template deploys a Standard\_D16s\_v3 Hyper-V host and bootstraps the host with the attendee environment.

-   It is recommended that you make sure you deploy the template into a region with support and availability of Standard\_D16s\_v3.

-   The template itself takes \~7-10 minutes to run, however there are a series of scripts and reboots which occur automatically as the host  is configured. This can take \~2-2.5 hours. It is recommended that you deploy the template and let the scripts run for at least that  amount of time before verifying the host.

    [![Deploy to Azure](OpenHack_BYOS-Migrationimages/media/image1.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fopenhackguides.blob.core.windows.net%2Fmigration-open-hack-artifacts%2Farmtemplates%2FazuredeployOnPrem.json)


- azuredeployCloudNetwork.json

-   In the same region as the resource group and resources created
    earlier, create another resource group called openhackcloudrg and
    deploy this template to it.

-   You can deploy this template at the same time as the first one.

-   This template takes \~45 minutes to execute as it stands up a VPN
    gateway.

    [![Deploy to Azure](OpenHack_BYOS-Migrationimages/media/image1.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fopenhackguides.blob.core.windows.net%2Fmigration-open-hack-artifacts%2Farmtemplates%2FazuredeployCloudNetwork.json)


# Services consumed

The following services are expected to be consumed over the duration of
the OpenHack. You should ensure that capacity is available and that
quotas for each subscription you are running the OpenHack in are at an
appropriate capacity.

Due to the open nature of OpenHack execution, services that are not on
this list may be consumed as well. Core consumption is expected to be at
least 30 cores per team per subscription.

## Required resources

The following are the required resources to successfully complete the
OpenHack.

  Service                            SKU                  Count   Cores
  ---------------------------------- -------------------- ------- ------------
  Azure Virtual Machines             Standard\_D16s\_v3   1       16
  Azure Virtual Machines             Standard\_Ds         5       Minimum 10
  Azure Virtual Machines             Standard\_Fs         5       Minimum 10
  Azure Active Directory             Free                 1       
  Azure App Service                  S1                   2       
  Azure SQL Database                 S0                   1       
  Azure App Gateway                  WAF\_v2              1       
  Public IP                          Standard             5       
  Azure Database Migration Service   Premium              1       
  App Service Domain                                      1       
  Azure Load Balancer                Standard             1       
  Azure Storage                      GPv1                 \~5     
  VPN Gateway                        VpnGw1               1       

## Other resources

The following are resources that teams have used in the past to complete
the OpenHack that are not required.

  Service                    SKU
  -------------------------- ------------------------------------------------------
  Azure App Service          Premium v2 Plan - P1 v2
  Azure App Service          SSL Certificates - Standard SSL - 1 Year Certificate
  Azure Key Vault            
  Azure Traffic Manager      
  Azure Front Door Service   
