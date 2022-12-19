# OpenHack Containers Overview

## Overview
**This OpenHack enables attendees to** modernize an application by moving to containers so that they can meet the demands of large - and scaling – workloads by working through challenges inspired from real-world scenarios.  
**During the “hacking” attendees will focus on** configuring an AKS cluster with production concerns in mind such as security (secret management and RBAC) and observability (logging and monitoring).   
**This OpenHack simulates a real-world scenario** where an insurance company’s current compute power on their core business application is not meeting the demands of their large, and scaling, workloads. The goal is to modernize the application and move it to the cloud.  
**By the end of the OpenHack**, attendees will have built out a technical solution that has cluster(s) ready for production and that meet top-quality security, observability and networking requirements.

## Technologies
Linux and Windows Containers, Azure Kubernetes Service, Azure Container Registry, Azure Virtual Machine, Networking, Azure Storage, Azure Monitor, Key Vault, Service Fabric Mesh

## Knowledge Prerequisites
**Knowledge Prerequisites**  
To be successful and get the most out of this OpenHack, it is highly recommended that participants have previous experience with:  
- Container basics
- Command line interface
- Web applications  

Required knowledge of [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/azure-fundamentals/).  
**Language-Specific Prerequisites**
- Recommended that participants have knowledge of programing languages like C#, JavaScript, Node.JS or Java.

**Tooling Prerequisites**
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
- A modern laptop running Windows 10 (1703 or higher), Mac OS X (10.13 or higher), or one of [these Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) 
- Install your choice of Integrated Development Environment (IDE) software, such as [Visual Studio](https://visualstudio.microsoft.com/vs/community/) or [Visual Studio Code](https://code.visualstudio.com/download)
- Download the latest version of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
- [Docker for Windows](https://docs.docker.com/docker-for-windows/install/) or [Docker for Mac ](https://docs.docker.com/docker-for-mac/install/)
- Terminal environment: PowerShell or [Bash](https://docs.microsoft.com/en-us/windows/wsl/install-win10) 
- [Download the latest Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) in the terminal of choice 
- [Install the latest release of Helm](https://helm.sh/docs/intro/install/)
- [Git](https://git-scm.com/downloads)

**Development Environment Configuration**
- Pull the SQL Server Docker image with the shell command:  
```docker pull mcr.microsoft.com/mssql/server:2017-latest```

**Links & Resources**
- Review the following links and resources: 
- [Introduction to Kubernetes ](https://docs.microsoft.com/en-us/learn/modules/intro-to-kubernetes/)  
- [Introduction to Kubernetes on Azure](https://docs.microsoft.com/en-us/learn/paths/intro-to-kubernetes-on-azure/)  
- D[ocker Networking](https://docs.docker.com/v17.09/engine/userguide/networking)  
- [Yaml Basics](https://linuxacademy.com/blog/devops/learn-the-yaml-basics/)  
- [Kubernetes Basics Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)  
**Optional** [AKS self-paced workshop](https://docs.microsoft.com/en-us/learn/modules/aks-workshop/) for more hands on preparation prior to the OpenHack event

**Post Learning Recommendations**
- [Administer containers in Azure](https://docs.microsoft.com/learn/paths/administer-containers-in-azure/)
- [Kubernetes Best Practices](https://learning.oreilly.com/library/view/kubernetes-best-practices/9781492056461/)
- [Kubernetes Patterns](https://learning.oreilly.com/library/view/kubernetes-patterns/9781492050278/)


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
- Deliver value to end-users of your application faster, with zero-downtime deployment 
- Focus on what matters – code and scale out! Rather than tediously manage compute on your own, use Kubernetes containers orchestration services (AKS) to easily real-time manage your clusters


## Technical Scenarios
- **Application Containerization**: Move services to container technology and leverage the cloud using AKS 
- **Security**: Networking, RBAC and secret management to ensure correct permissions for each cluster
- **Mixed-Workloads**: Running both Windows and Linux workloads in a single cluster
- **Observability**: The ability to understand and manage the health of your applications through tools like Azure Monitor

