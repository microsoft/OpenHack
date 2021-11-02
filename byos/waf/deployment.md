# Microsoft Azure Well-Architected Framework OpenHack

This deployment guide will assist you in deploying the required resources and artifacts for the Microsoft Azure Well-Architected OpenHack.

> Total deployment time may take **15-20 minutes** for provisioning Azure resources.

## Prerequisites

Because of the complexity of the deployment, it is _highly_ recommended to use Docker for deploying resources. While you can attempt to interpret the deployment shell script, it is not advised. Being as such, besides an Azure subscription and Azure DevOps account, **Docker is the _only_ prerequisite** and approximately 20GB of temporary space to build the container.

It is also worth noting that, unless limits have been increased, typical Azure tenants may not have the necessary compute allocation to deploy the initial resources.

## Artifacts

Beyond the deployment of the environments as described below, the following artifacts from the OpenHack _source_ should be deployed to their respective portal environment so that they are accessible to coaches and attendees during the event.

### Coach's Portal

The following artifacts should be deployed to the coach's portal:

* Coach's Guides: `/resources/guides/challenges/**/*`
* PowerPoint Decks
    * Tech Scenario: `/resources/ppt/OpenHack_Tech Scenario_Attendee_Coach_Deck_WAF.pptx`
    * Virtual Coach Standup: `/resources/ppt/OpenHack_Virtual_Coach Standup_WAF.pptx`
    * Virtual Know Before You Go (KBYG) Coach Prep: `/resources/ppt/OpenHack_Virtual_KBYG.Coach Prep Deck_WAF.pptx`
    * Virtual Opening Deck: `/resources/ppt/OpenHack_Virtual_Opening Deck_WAF.pptx`
* Sample Issues: `/resources/Sample_Issues.docx`
* Success Matrix: `/resources/successMatrix.xlsx`

### Attendee's Portal

The following artifacts should be deployed to the attendee's portal:

* Woodgrove Bank WAF Assessment: `/tools/Woodgrove_Bank_Assessment_2021-08-31.docx`
* Architecture Assessment Template: `/tools/Architecture_Assessment.docx`
* k6 Demo and Documentation: `/tools/k6/**/*`

## Deployment

Please fully read this section _prior to_ attempting a deployment. As stated above, Docker is recommended for deploying the OpenHack due to the deployment complexity. Therefore, all instructions will be based on this approach. Also, the Docker image is only required for _deployment_. Once the OpenHack has been deployed to your Azure and DevOps tenants, you can delete the local Docker image to reclaim space.

Deployment can be accomplished two ways: fully-automated and semi-automated. Both approaches are shared in detail below. All available parameters are listed, as well. Finally, some examples are provided for different scenarios.

>NOTE: During the deployment, generating the ARM template from the Bicep definition files will generate some warnings. This is expected and due to the Azure REST API not being updated.

### Fully-automated deployment

A fully-automated deployment **requires** that the one performing the deployment is a _Global Admin_ on the Azure tenant. This requirement is due to assigning the appropriate permissions (e.g. "admin consent") to the generated Azure AD app registrations. In a fully-automated deployment, the necessary app registrations are created automatically, are granted "admin consent," and a Personal Access Token (PAT) is automatically created in Azure DevOps.

Unless you are the IT manager of your company or attempting to deploy the OpenHack artifacts to a _personal_ subscription, this approach will not be available to you and, therefore, you should follow the semi-automated deployment method.

### Semi-automated deployment

In a semi-automated deployment, only a single service principal is created with RBAC privileges in the Azure tenant. You will be required to create a PAT in Azure DevOps during the deployment process.

A semi-automated deployment will be the necessary approach for most users, _including Microsoft employees_ wishing to deploy the OpenHack into their AIRS subscription.

### Stages of deployment

The deployment has four basic stages:

1) Create the required Azure identities
2) Deploy an Azure DevOps tenant
3) Deploy Azure portal artifacts
4) Deploy Azure DevOps artifacts

### Available parameters

The Azure AD REST APIs, unfortunately, are inconsistent with the returned JWT tokens. Therefore, a few different endpoints are required for deployment. For this reason, you will notice below that your Azure AD username and password are always required regardless of using a username/password or device login.

| Flag | Required | Description |
| :--: | :------: | ----------- |
| `-u` | **Yes** | Your Azure AD account email address. |
| `-p` | **Yes** | Your Azure AD account password.<br /><br />NOTE: It may be helpful to enclose your password in single quotes if your password contains special characters. |
| `-t` | **Yes** | Your Azure tenant unique ID (e.g., a GUID). |
| `-s` | **Yes** | Your Azure subscription ID (e.g., a GUID). | |
| `-d` | | If your tenant requires multi-factor authentication (MFA), this flag is **required**. This will allow you to authenticate in a browser in order to run Azure CLI commands as MFA restricts username/password authentication via `az login`. |
| `-m` | | If you are **NOT** a Global Admin on your Azure tenant, this flag is **required**. Setting this flag will provide you the opportunity to _manually_ create and apply an Azure DevOps PAT during the deployment process. |
| `-v` | | Enables verbose logging. |

### Manually generating a Personal Access Token (PAT) in Azure DevOps

If you are executing a semi-automated deployment (setting the `-m` flag), you will be prompted to create and provide a PAT _after the second stage_ of the deployment completes the creation of your Azure DevOps tenant.

The deployment script will inform you of the name of your newly created tenant (e.g. WAFOpenHack###### ). You will need to create a PAT with the two permissions listed below. Note that it is not important what name you assign to the PAT or its expiration date. The only requirements are that the PAT is assigned to the newly-created organization and setting the two permissions:

1) **Code** - _Full_
2) **Project and Team** - _Read, write, & manage_

> (NOTE: You will need to click on _"Show all scopes"_ at the bottom of the blade in order to find the **Project and Team** permission scope.)

![PAT requirements](images/pat_requirements.png)

If you need help creating a PAT, review the [documentation](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page).

### Examples

#### Build the Docker image

Prior to running any of the below examples, you will need to first build an image. In the project's root folder execute the following:

```bash
docker build -t wafopenhack
```

This will create a Docker container image called _wafopenhack_. You can actually choose whatever you'd like for the name of the container. However, the examples below assumes that you've chosen this name for your image.

> NOTE: Creating an image for the first time may take a few minutes and is largely dependent on how fast resources (other image layers) can be downloaded and the deployment application compiling.

#### Fully-automated deployment

Again, in order to execute this deployment you must be a _Global Admin_ on your Azure tenant _and_ MFA must **NOT** be required.

```bash
docker run -it wafopenhack -u <email> -p <password> -s <subscriptionId> -t <tenantId>
```

#### Using device login

This approach is used for Azure AD tenants _requiring_ MFA authentication.

```bash
docker run -it wafopenhack -u <email> -p <password> -s <subscriptionId> -t <tenantId> -d
```

Upon running this, you will be directed to a website where you will need to enter a code and authenticate. Upon successful authentication, the script will proceed.

#### Using a manually-generated PAT

This approach is used for Azure AD tenants _requiring_ MFA authentication.

```bash
docker run -it wafopenhack -u <email> -p <password> -s <subscriptionId> -t <tenantId> -m
```

As stated above, after your Azure DevOps tenant has been created, you will prompted to manually enter a PAT. Follow the requirements stated above for creating a PAT with the necessary permissions. Once, you've created the PAT, enter it at the prompt (copy and paste), then the deployment will continue.

#### Microsoft AIRS subscriptions (for Microsoft employees)

As stated previously, because of security limitations within the Microsoft tenant, you must use a combination of the device login and manually-generated PAT.

```bash
docker run -it wafopenhack -u <email> -p <password> -s <subscriptionId> -t <tenantId> -d -m
```

## Assistance

This deployment script, the artifacts within the repo, and any other content contained herein are provided with little assistance. Should you have questions or have issues, please open an _Issue_ in this repository.
