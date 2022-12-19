# OpenHack Migration Overview

## Overview
**The Migration OpenHack enables attendees** to securely assess, migrate, modernize, and optimize existing on-premises applications hosted in Windows Server 2008 R2 and Microsoft SQL Server 2008 R2 as they move to Microsoft Azure.

**The OpenHack simulates a real-world scenario where** a mortgage company has multiple line-of-business applications residing on legacy infrastructure that is rapidly approaching end-of-support and needs to be migrated. 

**During the “hacking” attendees will focus on**:
 1. Migrating their applications from legacy operating systems to Azure using a rehost methodology.
 2. Transitioning from IaaS to PaaS services that account for application behavior monitoring and security of organizational secrets. 
 
**By the end of the OpenHack, attendees will have built out a technical solution** that has all applications and virtual machines (all workloads) fully hosted on the Azure cloud.


## Technologies
Azure Migrate, Azure Database Migration Service, Data Migration Assistant, Azure Active Directory, Azure Active Directory Connect (AAD Connect), Azure Site Recovery, Azure Monitor/Log Analytics, Azure Networking, Azure Virtual Machines, Azure Storage, Azure DNS, Azure Traffic Manager, Azure Bastion, Azure Load Balancer, Azure Application Gateway

## Knowledge Prerequisites
**Knowledge Prerequisites**
To be successful and get the most out of this OpenHack, it is highly recommended that participants have previous experience with:
- Azure Compute + associated services
- Azure Networking
- Azure Storage
- Windows Server

Required knowledge of Azure fundamentals. 

**Language-Specific Prerequisites**:
None

**Tooling Prerequisites**

To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack:
- A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or one of these Ubuntu versions 
- Install your choice of Integrated Development Environment (IDE) software, such as Visual Studio, Visual Studio Code, Eclipse, or IntelliJ.
- Download the latest version of Azure CLI.

**Development Environment Configuration**
None

**Links & Resources**
- [Cloud migration in the Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/migrate/)
- [Azure migration guide: Before you start](https://docs.microsoft.com/azure/cloud-adoption-framework/migrate/azure-migration-guide/?tabs=MigrationTools)
- [Cloud rationalization](https://docs.microsoft.com/azure/cloud-adoption-framework/digital-estate/5-rs-of-rationalization)
- [Migration tools decision guide](https://docs.microsoft.com/azure/cloud-adoption-framework/decision-guides/migrate-decision-guide/)
- [SQL Server Data Tools ](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-ver15)/ [SQL Server Management Studio](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver15)
- Browser Client (e.g. Safari/Firefox)

**Post Learning Recommendations**
- [Architect migration, business continuity, and disaster recovery in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-migration-bcdr/)
- [SQL Server upgrades](https://docs.microsoft.com/en-us/learn/paths/sql-server-2017-upgrades/) 
- [Protecting, monitoring and tuning a migrated database ](https://docs.microsoft.com/en-us/learn/modules/protecting-monitoring-tuning-migrated-database/)
- [Prepare to migrate SAP workloads to Azure](https://docs.microsoft.com/en-us/learn/modules/prepare-migrate-sap-workloads/) 

## Challenge Overview
**Challenge 1: Establish your plan**

In this challenge, you will learn how to plan for the migration of servers from on-premises to Azure, including how to rationalize the selection of migration tooling based on the source environment, how to design a naming convention and establish governance with Microsoft Azure, and how to design a network topology in Azure that supports segmentation between applications and services using native Azure network security resources. You will use this plan to develop your foundational Azure infrastructure as you perform your migration.
Learning objectives:
- Plan a migration infrastructure
- Plan hybrid identity
- Design for resiliency
- Design a network infrastructure
- Plan for governance

**Challenge 2: Assess workloads for migration**

In this challenge, you will begin to assess your on-premises environment using tools which provide automated discovery of server-to-server communication and help you right-size your environment for performance and cost before you migrate. You will learn how these tools can be used to assess on-premises Windows Server virtual machines in Hyper-V by installing and configuring any necessary software and agents. You will also finalize the design of your Azure network, including planning for logical segmentation between applications and application tiers.
Learning objectives:
- Prepare for and assess virtualized on-premises environments
- Determine suitability of servers and workloads for fit in Azure
- Create formal assessments for business leaders which demonstrate cost and sizing

**Challenge 3: Implement hybrid identity**

In this challenge, you will learn how to establish hybrid identity to allow for seamless control and access to on-premises and Azure resources after migration. With hybrid identity established, your customer can use a single identity to access on-premises applications and cloud services such as Azure, Office 365, and other sites on the internet. Identity and assessment management (IAM) controls for Azure resources will be established which are needed for the duration of your migration.
Learning objectives:
- Plan hybrid identity
- Prepare on-premises environments for hybrid identity with Azure Active Directory
- Implement hybrid identity
- Implement identity access and management (IAM) using role-based access controls

**Challenge 4: Implement hybrid networking and resilient authentication**

In this challenge, you will establish the final pieces of your migration infrastructure by implementing connectivity between your on-premises environment and Azure. You will also build out domain controllers in Azure for high-availability and resiliency should the network link between on-premises and Azure ever degrade or become unavailable. All the resources you build will be secured using role-based access controls using identities and security groups that were synchronized to Azure in previous challenges.
Learning objectives:
- Design and implement site-to-site networking
- Design and implement highly available virtual machines

**Challenge 5: Test migration**

In this challenge, you will begin to perform migrations of servers and applications to Azure using a rehost methodology. The migrations you perform will be tested and validated in an isolated environment which does not impact production, allowing you to iterate and refine your migration process without fear of impacting existing workloads.
Learning objectives:
- Migrate workload to Azure for isolated testing
- Ensure secure and segmented cloud networks for migrated workloads
- Secure migrated servers for remote access

**Challenge 6: Finalize migration**

In this challenge, you will perform your final migration to Azure by implementing the process you refined in the previous challenge, bringing your customer over to Azure for the target workloads. The migration must be performed during a predefined outage window and must not impact the production environment in a manner which prevents failback to on-premises if the migration is unsuccessful. After a successful migration, you will retire the on-premises servers and workloads and clean up your migration infrastructure.
Learning objectives:
- Perform final migrations of servers to Azure
- Implement failback mechanisms for seamless migration
- Design and implement resources to minimize downtime 

**Challenge 7: Transition to platform database services**

In this challenge, you will help your customer increase the efficiency and agility for managing and developing applications based on legacy Microsoft SQL Server database workloads by implementing PaaS database services. To make this transition, you will migrate the existing databases from Microsoft SQL Server to a compatible database platform service and configure the existing application to use PaaS databases securely.
Learning objectives:
- Migrate from IaaS SQL Server VMs to database platform services 
- Assess databases for compatibility with database platform services
- Implement secure connectivity to PaaS services
- Configure platform services to meet backup and retention requirements

**Challenge 8: Transition to platform web-hosting services**

In this challenge, you will continue to improve the efficiency, scalability, and agility for the existing websites by migrating to PaaS service. In addition to migrating the websites and ensuring they are operable in the new environment; they will also be secured to meet customer requirements. This includes the implementation of SSL and using Azure identities to secure access to both Azure resources one of the underlying websites.
Learning objectives:
- Migrate from IaaS web servers to platform web-hosting services
- Implement SSL with platform services for custom applications
- Minimize downtime with URL reuse and build on services already in use from IaaS implementations
- Implement Azure AD authentication to meet customer requirements.

**Challenge 9: Secure, optimize, and operate**

In this challenge, you will learn how to optimize the current deployment by implementing elastic scale in your websites, how to secure your PaaS workloads through encryption of relational data with customer-managed keys and using an HSM to protect your application secrets. You will also learn how to implement real-time performance monitoring for your websites and how to implement alerting for degradations in service health within the Azure platform.
Learning objectives:
- Implement security features of PaaS services, including protecting application secrets
- Implement at-rest encryption for database platform services using customer-managed keys (CMK)
- Implement elastic scale for web applications with autoscale
- Configure performance insights for web applications hosted in Azure
- Configure Azure platform service health alerts

## Value Proposition
- Modernize your applications by moving away from outdated, expensive legacy infrastructure: discover, assess, and migrate on-premises applications, infrastructure, and data. 
- Take it step-by-step: centrally plan and track the migration across multiple Microsoft and third-party open-source tools.
- Increase resiliency and access to ongoing support for your legacy operating systems.

## Technical Scenarios
- Migration: move on-premises applications to Microsoft Azure
- Security: migration approach that minimizes data, app code, and other harmful leaks of information during transition from legacy infrastructure to the cloud with layers of testing and RBAC implementation
- Data: configure new Azure databases to meet your data ingestion, storage, and advanced search/AI needs
- Networking: ensure that your connection between on-prem and Cloud is secure and active, so resources transferred in between are protected

