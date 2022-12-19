# OpenHack Security, Compliance, and Identity Overview


## Overview
**This OpenHack enables participants to** establish and defend baseline security and compliance configurations for organizations using Microsoft cloud services. This will be done with Microsoft Security and Compliance tools and recommended security best-practices by working through challenges inspired from real-world scenarios.

**During the “hacking” participants will focus on** analyzing and remediating security configurations in a pre-configured Microsoft online organization. Additionally, participants will implement security and compliance policies to enforce regulations required by the company and mitigate any threats discovered during the assessment. 

**By the end of the OpenHack**,  participants will have gained the knowledge on how to better protect an organization that uses hybrid cloud organizations leveraging SaaS, IaaS and PaaS solutions. Participants will also gain experience creating policies and procedures to meet the compliance needs of an organization. …(to what level/degree?)

## Technologies
Microsoft Defender for Office 365, Compliance Manager, Microsoft 365 Defender, Microsoft Secure Score, Secure score in Microsoft Defender for Cloud, Azure Regulator compliance, Microsoft Defender for Cloud, Azure policy, Microsoft Defender for Cloud - Policy, Azure Identity protection, Microsoft Defender for Cloud Apps, Microsoft Defender for Identity, Data loss prevention, Microsoft Sentinel
## Knowledge Prerequisites
**Knowledge Prerequisites**
To be successful and get the most out of this OpenHack, it is highly recommended that participants have previous experience with:
- Azure Active Directory
- Microsoft 365 Security and Compliance
- Microsoft Defender for Cloud

Required knowledge of [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/az-900-describe-cloud-concepts/).  
**Tooling Prerequisites**

To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
- A modern laptop running Windows 10 (1703 or higher), Mac OS X (10.13 or higher), or one of these Ubuntu versions 
Links & Resources
Review the following links and resources: 
- How to organize your security team: The evolution of cybersecurity roles and responsibilities
- Threat Modeling
- Microsoft security blog
- Security, Compliance & Identity

Post Learning Recommendations
- Security Engineer
- Microsoft Certified: Security, Compliance, and Identity Fundamentals
- Demonstrate fundamental knowledge of Microsoft 365 security and compliance capabilities

To be successful and get the most out of this OpenHack, it is highly recommended that participants have previous experience with:
- Azure Active Directory
- Microsoft 365 Security and Compliance
- Microsoft Defender for Cloud
Required knowledge of Azure fundamentals.
Tooling Prerequisites
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
- A modern laptop running Windows 10 (1703 or higher), Mac OS X (10.13 or higher), or one of these Ubuntu versions 
Links & Resources
Review the following links and resources: 
- How to organize your security team: The evolution of cybersecurity roles and responsibilities
- Threat Modeling
- Microsoft security blog
- Security, Compliance & Identity

Post Learning Recommendations
- Security Engineer
- Microsoft Certified: Security, Compliance, and Identity Fundamentals
- Demonstrate fundamental knowledge of Microsoft 365 security and compliance capabilities

## Challenge Overview
**Challenge 1: But First, Containers**  
In this challenge, you will familiarize yourself with container basics.
Learning objectives:
- Use Docker to build and run containers locally
- Push images to Azure Container Registry

**Challenge 2: Getting Ready for Orchestration**   
In this challenge, you will familiarize yourself with the Kubernetes basics.  
Learning objectives:
- Deploy microservices to a basic Azure Kubernetes Service cluster
- Get familiar with basic Kubernetes concepts

**Challenge 3: To Orchestration and Beyond**  
In this challenge, you will deploy into existing network space and implement some security measures.  
Learning objectives:  
- Use Azure Kubernetes Service to configure and create an RBAC enabled Kubernetes cluster in an existing VNET
- Use namespaces to logically separate microservices 
- Deploy containers from Challenge 1 to the Kubernetes cluster with proper RBAC configurations 

**Challenge 4: Putting the Pieces Together**  
In this challenge, you will better secure workload secrets and create routing rules for traffic to your microservices.  
Learning objectives:  
- Implement Ingress for the application on the cluster
- Manage and secure secrets with Azure Key Vault

**Challenge 5: Wait, What’s Happening?**  
In this challenge, you will improve the observability of your cluster.  
Learning objectives:
- Use Azure Monitor or Prometheus and Grafana to monitor the health of the AKS cluster
- Create alerts to detect issues

**Challenge 6: Locking it Down**  
In this challenge, you will further improve the security of your cluster.  
Learning objectives:
- Improve cluster security using network policies and pod security policies
- Further configure RBAC roles and permissions for the AKS cluster
- Update a microservice to use managed identity authentication via Pod Identity

**Challenge 7: Mixed Emotions**  
In this challenge, you will deploy a mixed workload (Linux and Windows) into a single cluster.  
Learning objectives:
- Add Windows nodes to AKS cluster and deploy a legacy Windows app
- Use Taints and Tolerations to implement best practices when running mixed workloads in a cluster
- Upgrade a deployment in the cluster  

**Challenge 8: Doing More with Service Mesh**  
In this challenge, you will explore the capabilities of a Service Mesh.  
Learning objectives:
- Use service mesh technology to expand on security and observability

## Value Proposition
- **Deliver value to end-users** of your application faster, with zero-downtime deployment 
- **Focus on what matters** – code and scale out! Rather than tediously manage compute on your own, use Kubernetes containers orchestration services (AKS) to easily real-time manage your clusters


## Technical Scenarios
- **Application Containerization**: Move services to container technology and leverage the cloud using AKS 
- Security: Networking, RBAC and secret management to ensure correct permissions for each cluster
- Mixed-Workloads: Running both Windows and Linux workloads in a single cluster
- Observability: The ability to understand and manage the health of your applications through tools like Azure Monitor

