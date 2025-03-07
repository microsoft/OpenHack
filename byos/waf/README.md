# WAF OH Outline

The below defines the individual challenges, along with their abstract, any requirements, and their expected objectives.

## Overview

The **Microsoft Azure Well-Architected Framework OpenHack** attempts to test the participants' understanding of the Microsoft Azure Well-Architected pillars. During the OpenHack, participants will demonstrate and practice a standardized process of conducting a Well-Architected assessment across all five of its pillars against a customer's workload.

The **Microsoft Azure Well-Architected Framework OpenHack** simulates a real-world scenario of a bank who has attempted to deploy a production workload to Azure.  Unfortunately, the bank was unaware of the Well-Architected pillars and proven design patterns, therefore, the production workload fails in many areas.

During the "hacking," attendees will focus on:

1. Analyzing and identifying enhancements to the customer's environment
2. Strengthening the customer's operational landscape
3. Ensuring that the customer's experience with the Microsoft cloud is of the utmost quality, value, and excellence

By the end of the OpenHack, it is expected that attendees will be familiar with the Microsoft Azure Well-Architected Framework and able to conduct an assessment against a customer's workload in the Azure cloud.

## Business Outcomes

When conducting a Well-Architected Assessment, Cloud Solution Architects (CSAs) will follow the  standardized process outlined below. This standard process is designed to drive an expected, high-level business value to the customer and to Microsoft. By participating in this OpenHack, CSAs will:

* Perform detailed analysis of customer workloads within the Well-Architected Framework.  
* Solidify and demonstrate the knowledge of each pillar of the Well-Architected Framework.  
* Demonstrate the ability to follow the standardized process of technical assessments while maintaining expected quality and rigor.  
* Recognize the benefits of applying any pillar of the Well-Architected Framework against a customer's environment.  
* Identify the value of a wholistic application of the Well-Architected Framework against a customer's environment.  
* Deliver appropriate recommendations across all pillars of the Well-Architected Framework.  
* Accelerate and build their own technical intensity.  

## Technologies

* [Azure DevOps](https://docs.microsoft.com/azure/devops/)
* [Azure Bicep/ARM Templates](https://docs.microsoft.com/azure/azure-resource-manager/bicep/)
* [Azure Key Value](https://docs.microsoft.com/azure/key-vault)
* [Azure Traffic Manager](https://docs.microsoft.com/azure/traffic-manager)
* [Virtual Machines](https://docs.microsoft.com/azure/virtual-machines/windows/overview)
* [Azure App Service](https://docs.microsoft.com/azure/app-service/)
* [Azure SQL](https://docs.microsoft.com/azure/azure-sql/)
* [Azure Load Balancer](https://docs.microsoft.com/azure/load-balancer/)
* [Application Gateway - WAF v2](https://docs.microsoft.com/azure/application-gateway/)
* [Azure Front Door](https://docs.microsoft.com/azure/frontdoor/)
* [Azure Cost Management](https://docs.microsoft.com/azure/cost-management-billing/)
* [Azure vNets](https://docs.microsoft.com/azure/virtual-network)
* [Azure Service Endpoints](https://docs.microsoft.com/azure/virtual-network/virtual-network-service-endpoints-overview)
* [Azure Monitor](https://docs.microsoft.com/azure/azure-monitor/)
* [Azure Defender](https://docs.microsoft.com/azure/security-center/azure-defender)
* [Azure Sentinel](https://docs.microsoft.com/azure/sentinel/)
* [Grafana](https://grafana.com/docs/)

## Prerequisites

### Knowledge Prerequisites

To be successful and get the most out of this OpenHack, it is highly recommended that participants have a deep understanding (L400+) of the following:

* [Microsoft Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
* [Cloud Design Patterns](https://docs.microsoft.com/azure/architecture/patterns/index-patterns)

Additionally, teams should be deeply familiar with the technologies listed above.

Finally, participants should have a strong operational knowledge (L300+) of the following technologies:

* [Azure DevOps Build/Release Pipelines](https://docs.microsoft.com/azure/devops/pipelines/get-started/what-is-azure-pipelines)
* [Azure Bicep](https://docs.microsoft.com/azure/azure-resource-manager/templates/bicep-overview)
* [Azure CLI](https://docs.microsoft.com/cli/azure/)

### Training Prerequisites

For preparation in passing the required challenges, participants are required to have completed all WAF training available via MS Learn. Additionally, it is expected that participants have completed pillar-specific hands-on learning labs.

### Tooling Prerequisites

To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack:

* A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or Ubuntu (16.04 or higher)
* Install your choice of Integrated Development Environment (IDE) software, such as [Visual Studio](https://visualstudio.microsoft.com/) or [Visual Studio Code](https://visualstudio.microsoft.com/)
* Download the latest version of [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
* Download the latest version of [Azure Bicep CLI](https://github.com/Azure/bicep/blob/main/docs/installing.md)
* For performance tests, install [k6 CLI](https://k6.io/docs/getting-started/installation/) (to install k6 CLI on Windows, you'll first need to install [Chocolatey Package Manager](https://chocolatey.org/install)) or install [Docker Desktop](https://docs.docker.com/engine/install/)
* To build applications locally, participants will need to download and install [.NET Core 5.0 SDK](https://dotnet.microsoft.com/download)

### Development Environment Configuration

Each team will need the following resources for the OpenHack:

* An Azure subscription with _Owner_ privileges. The teams will be required to create Service Principals to connect Azure DevOps for deploying templates and to connect Grafana to Azure Monitor.
* An Azure DevOps tenant with _Project Collection Administrator_ privileges. The tenant will contain two projects along with source code for the OpenHack.

A deployment guide can be found in the public [BYOS repo](https://github.com/microsoft/OpenHack/blob/main/byos/waf/deployment.md).

### Language-Specific Resources

The following languages/technologies are not required of _each participant_. However, the team, as a whole, should be able to cover the following together.

* **C#** - Some understanding is necessary for comprehending source code and completing later challenges.
* **JavaScript** - An extremely elementary knowledge is required if participants wish to understand the code. Otherwise, they will only be updating a few strings at the beginning of a script.
* **SQL (Entity Framework) with SQL Profiler** - Teams should be able to identify under performing queries and have the ability to optimize, as necessary.
* **YAML for Azure DevOps Build/Release Pipelines** - Initial YAML files are provided. However, teams must be able to update the scripts, as necessary, to complete challenges. (NOTE: Teams may wish to leverage GitHub workflows but doing so is outside the scope of this OpenHack.)
* **Azure Bicep** - The infrastructure is built using Azure Bicep, along with some desired state configurations (DSC). Teams will need to know how to develop Azure Bicep scripts in order to complete the Infrastructure-as-Code (IaC) components of this OpenHack. (NOTE: Teams may also leverage pure ARM templates or Terraform. However, both are outside the scope of this OpenHack and may prove to cost the team valuable time.)

### Links & Resources

Besides the foundation knowledge requirements outlined above, below are a few additional resources that may be helpful prior to beginning this OpenHack.

#### General

* [Microsoft Assessments: Azure Well-Architected Review](https://docs.microsoft.com/assessments/?mode=pre-assessment&id=azure-architecture-review)

#### DevSecOps

* [DevSecOps in Azure](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/devsecops-in-azure) (NOTE: While some content centers around AKS and Terraform, the general concepts are the same.)
* [Design a CI/CD pipeline using Azure DevOps](https://docs.microsoft.com/azure/architecture/example-scenario/apps/devops-dotnet-webapp)
* [End-to-end governance in Azure when using CI/CD](https://docs.microsoft.com/azure/architecture/example-scenario/governance/end-to-end-governance-in-azure)
* [DevTest and DevOps for IaaS solutions](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/dev-test-iaas)
* [CI/CD for Azure VMs](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/cicd-for-azure-vms)
* [DevTest and DevOps for PaaS solutions](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/dev-test-paas)
* [CI/CD for Azure Web Apps](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/azure-devops-continuous-integration-and-continuous-deployment-for-azure-web-apps)
* [DevOps in a hybrid environment](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/devops-in-a-hybrid-environment)
* [Implementation reference for load testing pipeline solution](https://docs.microsoft.com/azure/architecture/example-scenario/banking/jmeter-load-testing-pipeline-implementation-reference) (NOTE: Documentation is specific to JMeter but can be adapted to k6.)
* [Hybrid availability and performance monitoring](https://docs.microsoft.com/azure/architecture/hybrid/hybrid-perf-monitoring)
* [Centralized app configuration and security](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/appconfig-key-vault)
* [Secure and govern workloads with network level segmentation](https://docs.microsoft.com/azure/architecture/reference-architectures/hybrid-networking/network-level-segmentation)
* [Security considerations for highly sensitive IaaS apps in Azure](https://docs.microsoft.com/azure/architecture/reference-architectures/n-tier/high-security-iaas)
* [Threat indicators for cyber threat intelligence in Azure Sentinel](https://docs.microsoft.com/azure/architecture/example-scenario/data/sentinel-threat-intelligence)
* [Web application monitoring on Azure](https://docs.microsoft.com/azure/architecture/reference-architectures/app-service-web-app/app-monitoring)

#### Core Networking

* [Zero-trust network for web applications with Azure Firewall and Application Gateway](https://docs.microsoft.com/azure/architecture/example-scenario/gateway/application-gateway-before-azure-firewall)
* [Multi-region load balancing with Traffic Manager and Application Gateway](https://docs.microsoft.com/azure/architecture/high-availability/reference-architecture-traffic-manager-application-gateway)
* [Protect APIs with Application Gateway and API Management](https://docs.microsoft.com/azure/architecture/reference-architectures/apis/protect-apis)
* [Azure Firewall architecture overview](https://docs.microsoft.com/azure/architecture/example-scenario/firewalls/)
* [Securely managed web applications](https://docs.microsoft.com/azure/architecture/example-scenario/apps/fully-managed-secure-apps)

#### Infrastructure

* [IaaS: Web application with relational database](https://docs.microsoft.com/azure/architecture/high-availability/ref-arch-iaas-web-and-db)
* [Basic Web Application](https://docs.microsoft.com/azure/architecture/reference-architectures/app-service-web-app/basic-web-app)
* [Multi-region web app with private connectivity to database](https://docs.microsoft.com/azure/architecture/example-scenario/sql-failover/app-service-private-sql-multi-region)
* [Enterprise deployment using App Services Environment](https://docs.microsoft.com/azure/architecture/reference-architectures/enterprise-integration/ase-standard-deployment)
* [High availability enterprise deployment using App Services Environment](https://docs.microsoft.com/azure/architecture/reference-architectures/enterprise-integration/ase-high-availability-deployment)
* [High availability and disaster recovery scenarios for IaaS apps](https://docs.microsoft.com/azure/architecture/example-scenario/infrastructure/iaas-high-availability-disaster-recovery)
* [Build high availability into your BCDR strategy](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/build-high-availability-into-your-bcdr-strategy)
* [Highly available multi-region web application](https://docs.microsoft.com/azure/architecture/reference-architectures/app-service-web-app/multi-region)

#### Applications

* [Unified logging for microservices applications](https://docs.microsoft.com/azure/architecture/example-scenario/logging/unified-logging)
* [Modernize .NET applications](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/net-app-modernization)
* [Scalable Web Apps](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/scalable-web-apps)
* [Simple branded website](https://docs.microsoft.com/azure/architecture/solution-ideas/articles/simple-branded-website)
* [Serverless web application](https://docs.microsoft.com/azure/architecture/reference-architectures/serverless/web-app)

### Post-Learning Recommendations

_TBD._  
_CSU is currently determining a “post-learning” process. I can complete this section once those details are finalized._

## Challenges

### Challenge 1: Assess the environment

In this challenge, you will assess a customer's production environment that has been deployed to Azure and currently hosting a live workload. You will gain an understanding of the customer's current process for deployment and management of the applications and supporting cloud resources. Part of this understanding will include performing a cost analysis of the Azure environment and establishing some baseline performance metrics. Based upon the assessment, you will need to craft a plan to assist the customer in adoption and implementation of the Microsoft Azure Well-Architected Framework. You will use this plan to govern how you proceed in future challenges.

#### Required  

Yes

#### Learning Objectives

* Inventory current components
* Identify potential areas of improvement
* Perform a cost analysis of the environment
* Conduct an initial performance test
* Conduct a load test against current business SLAs
* Conduct a stress test
* Establish and document performance baselines
* Understand the difference between the three types of performance tests
* Demonstrate a basic understanding of WAF
* Document any initial concerns for business meeting SLAs

### Challenge 2: Operationalize automated deployments

In this challenge, you will assist the customer in adopting automated deployments of both the application and infrastructure. You will explore the Azure Bicep scripts included in the Azure DevOps project and learn how to convert them to ARM templates for environment configuration and deployments. When helping the customer automate infrastructure and application changes, you will configure build and release pipelines. You will also attach deployment gates to release pipelines for security and governance of cloud resources. Deployments should ensure that only the correct resources should be removed by reporting changes _prior to_ being executed. It is important that you have a firm understanding of Azure Bicep and that your pipelines are configured correctly as **all future changes to the Azure environment must be conducted through the pipelines**.

#### Required  

Yes

#### Learning Objectives

* Create build/release pipelines in Azure DevOps
* Determine best strategy for deployments (conditions, types, etc.)
* Demonstrate "what-if" scenarios with deployments
* Configure gated deployments
* Discuss deployment models to maximize uptime

### Challenge 3: Planning for failure

It is not a matter of _if_ an environment will fail, but _when_. Therefore, prior to any changes being introduced into the application or its supporting infrastructure, it is important that proper monitoring and alerting be configured. In this challenge, you will determine what types of monitoring, along with the necessary data points, should be conducted. You will also determine and configure any necessary alerting of activities within your environment. These activities could include, but are not limited to, resource availability (or lack thereof), security threats, etc. Finally, you will determine a BCDR strategy in which you will implement in a future challenge.

#### Required  

Yes

#### Learning Objectives

* Discuss potential alerting options and processes
* Compose a list of metrics that should be monitored
* Compose a list of conditions that should generate an alert
* Configure alerting for determined conditions
* Demonstrate a successful alert
* Configure Azure Monitor and Security Center
* Enable Azure Sentinel
* Discuss BCDR strategy, including the varying costs of potential solutions relative to RPO/RTO/SLAs/KPIs
* Document BCDR strategy
* Identify points (roles) of contact for failures in the environment and construct a RACI chart

### Challenge 4: Visualizing operations

Now that significant planning and documentation has been completed, it is time to begin executing those plans. However, one last thing to consider is _visualizing_ changes across your environment. In this short challenge, you will take the composed list of metrics and conditions from the last challenge and build some operational dashboards. You will create a free Grafana account and link your Azure Monitor instance to it. You will then build some time-series reports and create an operational dashboard.

#### Required  

Yes

#### Learning Objectives

* Creating demo Grafana account
* Linking Azure Monitor to Grafana
* Creating operational dashboard in Grafana
* Reporting on IaaS resources
* Discuss the benefits and use cases of a real-time operational dashboard

### Challenge 5: Improve the environment

Before any changes are introduced into the current application architecture, the customer is interested in hardening what is currently deployed in terms of security, redundancy, and overall optimization. In this challenge, you will leave the application structure as-is&mdash;leaving it running on VMs&mdash;but you will implement some changes to the deployments and configurations of the environment. You will need to address secrets, potential areas of attack, and resiliency within the application. You will also need to make sure the telemetry is captured from the application and the virtual machine.

#### Required  

Yes

#### Learning Objectives

* Right-sizing VMs
* Redundancy of VMs using Availability Zones and proper storage configurations
* Securing network resources using NSGs
* Implementing JIT on VMs
* Discuss and properly configure RBAC based on RACI matrix
* Discuss options for securing database connection strings and implement a solution  
* Adding Application Insights to an application
* Configuring VM to send telemetry via Application Insights or Log Analytics agent
* Replacing ELB with Application Gateway and configuring OWASP
* Comparing performance to baselines and ensuring that business SLAs are met with changes in architecture
* Discuss potential cost improvements (Azure Reserved Instances)

### Challenge 6: Leveraging PaaS services

Often, customers choose to build their own environments for services already managed by Microsoft or its partners. This customer is no different. In this challenge, you will begin migrating the components of the web application to Azure's various PaaS offerings. As you migrate the application and configure its services, you must consider all pillars of the Microsoft AzureWell-Architected Framework. With your implementation, you will need to ensure that all of the customer's SLAs are able to be met _at all times_ while maintaining adherence to the Microsoft Azure Well-Architected Framework. You will also need to make sure that your Grafana dashboards are updated to report desired metrics from the new resources. Finally, all alerts should be updated based on the new resources.

#### Required  

Yes

#### Learning Objectives

* Configuring Azure App Service for autoscale
* Securing Azure App Service
* Configuring Azure SQL for failover
* Using Key Vault in Azure App Service
* Enabling SQL Always Encrypted
* Leveraging private endpoints
* Using Azure Batch
* Continuing to compare performance to baselines and ensuring that business SLAs are met with changes in architecture
* Failing a region while maintaining performance SLAs
* Reporting on PaaS services

### Challenge 7: Optimizing the API

In the previous challenge, you may have elected to move the API to Azure Functions. If so, great! If not, here is your chance. In this challenge, you will separate the web front-end (WFE) from its services layer (API). Upon doing so, you will move the service layer to Azure Functions. In light of the Microsoft Azure Well-Architected Framework, you will also need to configure Azure Functions accordingly.

#### Required  

No

#### Learning Objectives

* Separating an application's front-end from its API
* Securing of Azure Functions
* Configuring autoscaling of Azure Functions
* Instrumenting Azure Functions with Application Insights
* Discuss the various billing models of Azure Functions and the reasoning behind which one was chosen in the case of this challenge
* Discuss the benefits of separating the two layers of the application
* Continuing to compare performance to baselines and ensuring that business SLAs are met with introduction of Azure Functions

### Challenge 8: Tightening database security

The application, unfortunately, is still using legacy database connection strings. This means that there are still identities (SQL or Azure AD) that are used to connect the application to the database. In this challenge, you will refactor your application to leverage managed identities for database connectivity and remove application-specific named users from the database.

#### Required  

No

#### Learning Objectives

* Using managed identities for database connectivity
* Understand and discuss the benefits of managed identities in terms of the Microsoft Azure Well-Architected Framework

### Challenge 9: Capturing correlation data

You have already introduced Application Insights into your application. However, the customer is finding it difficult to correlate errors between the web front-end and the backend. In this challenge, you will _discuss_ approaches to implementing the capturing of correlation data when an error occurs in the application. Remember, solutions should consider all pillars of the Well-Architected Framework.

#### Required  

No

#### Learning Objectives

* Discuss techniques for capturing correlation data
* Understand costs and security when storing correlation data
* Understand how processing correlation data can impact application performance
* Understand what data to capture in a distributed architecture

## Value Proposition

* Understand and clearly articulate the Microsoft Azure Well-Architected Framework and each of its pillars, along with the respective benefits
* Systematically analyze a given workload under the individual lenses of the Well-Architected Framework pillars
* Deliver appropriate recommendations based on standard proven practices in accordance with the Well-Architected Framework
* Successfully implement and migrate existing workloads to optimize and strengthen said workloads in all pillars of the Well-Architected Framework
* Increase the overall technical intensity of technical team members

## Technical Scenarios

* _Performance_ - test and maintain, if not improve, performance of the application and its supporting infrastructure in order to meet specified SLAs
* _Resiliency_ - develop a BCDR strategy and architect an environment to which to migrate a customer's workload that will maximize uptime
* _Security_ - ensure that all connections to and from the application, including the database and its data, are secure, and verify access to cloud resources are restricted to necessary teams via appropriate RBAC policies
* _Modernization_ - transition a traditional, monolithic web application to modern PaaS services

## Audience

* Target Audience:
    * Microsoft - CE, CSE, CSA, GBB, ATT, CE, SE, TPM
    * Customer - Developers, Architects, SREs, DevOps Engineers, Systems Integrators, Systems Administrators
* Target Verticals: All
* Customer Profiles:
    * Customers who are looking to deploy new cloud-native applications and/or infrastructure into Azure and wish to have an assessment conducted on the workload prior to it going live.
    * Customers who currently have cloud-native applications running in production and are seeking visibility into optimization in terms of cost, security, reliability, and/or performance.
    * Customers who have migrated traditional, on-premises workloads to Azure and are seeking additional assistance in optimization for cloud operations.

## Registration Questions

| Required | Field | Response Options |
| -------- | ----- | ---------------- |
| **Yes**  | What is your level of understanding using Azure today?    | None<br />Some understanding<br />I have some pilot work on Azure<br />I heavily rely on Azure today for cloud|
| **Yes**  | What is your level of understanding of the Azure Architecture Center? | None<br />Some understanding<br />I use it occasionally<br />I use it frequently |
| **Yes**  | What is your level of understanding of Cloud Design Patterns? | None<br />Some understanding<br />I reference them occasionally<br />I reference them frequently |
| **Yes**  | What is your level of understanding of the Microsoft Azure Well-Architected Framework? | None<br />Some understanding<br />Intermediate knowledge<br />Expert |
| **Yes**  | Which area most closely aligns to your expertise/role? | Developer<br />Infrastructure<br />Data<br />Security<br />Other |
| **Yes**  | How many years of experience do you have in your area? | &lt; 1 year<br />1-5 years<br />5-10 years<br />10+ years |
| **Yes** | Which level of understanding do you have in (separate answer for each of the following areas):<br /><br /><ul><li>Performance testing</li><li>Azure DevOps Build/Release Pipelines</li><li>Azure Bicep, ARM Templates</li><li>Core Azure IaaS services</li><li>Core Azure PaaS services</li><li>Azure Networking</li><li>Cost Management</li><li>Azure Monitor</li><li>Grafana</li><li>Cloud &amp; application security</li><li>Business continuity and disaster recovery (BCDR)</li></ul> | None<br />Introductory<br />Fundamental<br />Intermediate<br />Advanced |

## FAQs

Q: Are there any pre-requisites to attending this OpenHack?  
A: Yes. Attendees should have completed all MS Learn modules for WAF and the Hands-On Labs for the individual pillars.

Q: Are there any OpenHacks that I should complete or would be considered advantageous to complete before participating in Microsoft Azure Well-Architected Framework OpenHack?  
A: Yes. While the following OpenHacks are not required, they could provide some fundamental understanding in many of the principles covered in the Microsoft Azure Well-Architected Framework OpenHack.

* App Modernization with NoSQL
* DevOps
* Migration (Line of Business)
* Serverless

Q: I have been working in Azure for years. Is this OpenHack really necessary?  
A: Yes. There are elements of the Microsoft Azure Well-Architected Framework with which you may be unfamiliar. This OpenHack will help solidify your knowledge of all five pillars.

Q: For which technology vertical is this OpenHack designed?  
A. The Microsoft Azure Well-Architected Framework is not for any single role or vertical but for all technology professionals. Furthermore, while this OpenHack is designed to challenge any IT professional who works in the cloud, many insights can be gleaned for those who work with on-premises environments.

## Technical Scenarios

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

The following artifacts will be deployed to the public artifacts repo:

* Woodgrove Bank WAF Assessment: `/tools/Woodgrove_Bank_Assessment_2021-08-31.docx`
* Architecture Assessment Template: `/tools/Architecture_Assessment.docx`
* k6 Demo and Documentation: `/tools/k6/**/*`

## Deployment

Please fully read this section _prior to_ attempting a deployment. As stated above, Docker is recommended for deploying the OpenHack due to the deployment complexity. Therefore, all instructions will be based on this approach. Also, the Docker image is only required for _deployment_. Once the OpenHack has been deployed to your Azure and DevOps tenants, you can delete the local Docker image to reclaim space.

All available parameters for deployments are listed below. Additionally, some examples are provided for different scenarios.

>NOTE: During the deployment, generating the ARM template from the Bicep definition files will generate some warnings. This is expected and due to the Azure REST API not being updated.

In a deployment, only a single service principal is created with RBAC privileges in the Azure tenant. You will be required to supply a pre-configured Azure DevOps tenant and a PAT for the deployment process.

### Stages of deployment

The deployment has four basic stages:

1) Create the required Azure identity
2) Deploy Azure portal artifacts
3) Deploy Azure DevOps artifacts

### Available parameters

Azure AD username and password are always required if you are **NOT** using a device login.

| Flag | Required | Description |
| :--: | :------: | ----------- |
| `-u` | | **REQUIRED IF NOT USING "Device Login."**<br />Your Azure AD account email address. |
| `-p` | | **REQUIRED IF NOT USING "Device Login."**<br />Your Azure AD account password.<br /><br />NOTE: It may be helpful to enclose your password in single quotes if your password contains special characters. |
| `-t` | **Yes** | Your Azure tenant unique ID (for example, a GUID). |
| `-s` | **Yes** | Your Azure subscription ID (for example, a GUID). |
| `-a` | **Yes** | The name of your pre-created Azure DevOps tenant. |
| `-m` | **Yes** | Your _manually created_ Azure DevOps Personal Access Token (PAT). |
| `-d` | | If your tenant requires multi-factor authentication (MFA), this flag is **required**. This will allow you to authenticate in a browser in order to run Azure CLI commands as MFA restricts username/password authentication via `az login`. |
| `-v` | | Enables verbose logging. |

### Manually generating a Personal Access Token (PAT) in Azure DevOps

You will need to create a PAT with the two permissions listed below. Note that it is not important what name you assign to the PAT or its expiration date. The only requirements are that the PAT is assigned to your Azure DevOps organization and setting the two permissions:

1) **Code** - _Full_
2) **Project and Team** - _Read, write, & manage_

> (NOTE: You will need to click on _"Show all scopes"_ at the bottom of the blade in order to find the **Project and Team** permission scope.)

![PAT requirements](pat_requirements.png)

If you need help creating a PAT, review the [documentation](https://docs.microsoft.com/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=preview-page).

### Examples

#### Build the Docker image

Prior to running any of the below examples, you will need to first build an image. In the project's root folder execute the following:

```bash
docker build . -t wafopenhack
```

This will create a Docker container image called _wafopenhack_. You can actually choose whatever you'd like for the name of the container. However, the examples below assumes that you've chosen this name for your image.

> NOTE: Creating an image for the first time may take a few minutes and is largely dependent on how fast resources (other image layers) can be downloaded and the deployment application compiling.

#### Using device login

This approach is used for Azure AD tenants _requiring_ MFA authentication.

```bash
docker run -it wafopenhack -s <subscriptionId> -t <tenantId> -a <devOpsTenant> -m <PAT> -d
```

Upon running this, you will be directed to a website where you will need to enter a code and authenticate. Upon successful authentication, the script will proceed.

#### Using a username and password

This approach is used for Azure AD tenants _not_ requiring MFA authentication.

```bash
docker run -it wafopenhack -u <email> -p <password> -s <subscriptionId> -t <tenantId> -a <devOpsTenant> -m <PAT>
```

## Assistance

This deployment script, the artifacts within the repo, and any other content contained herein are provided with little assistance. Should you have questions or have issues, please open an _Issue_ in this repository.
