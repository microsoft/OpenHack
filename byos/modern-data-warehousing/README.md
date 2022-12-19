# OpenHack Containers Overview


## Overview
This OpenHack enables attendees to develop, implement, and operationalize ETL pipelines for a multi-source data warehouse solution on Microsoft Azure. 
This OpenHack simulates a real-world scenario where an online DVD company’s data is coming in from a mess of disparate sources but needs to be stored in a single location, interpreted, and then used to feed a wide variety of downstream systems. 
During the hack, attendees will focus on: 
1.	Systematically ingesting and securing data from multiple sources.
2.	Transforming data to fit business’s required schema and monitor dataflow with levels of DevOps testing. 

By the end of the OpenHack, attendees will have built out a technical solution that is a fully operating Modern Data Warehouse with corresponding CI/CD pipeline that takes into account data management that meets top-quality data consumption requirements like reliability, scalability, and maintainability.

## Technologies
Azure Data Lake Storage, Azure Data Factory, Azure Databricks, Azure DevOps, Azure Synapse Analytics

## Knowledge Prerequisites
**Knowledge Prerequisites**   
To be successful and get the most out of this OpenHack, participants should have existing knowledge of relational database structures and concepts (e.g. tables, joins, SQL) and experience with either SSIS or programming languages like Scala or Python. Previous experience creating ETL pipelines, source control management, automated testing, and build and release automation will help you advance more quickly.
Required knowledge of Azure fundamentals. 

**Language-Specific Prerequisites**  
- Programming languages like Scala or Python.

**Tooling Prerequisites**  
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack:
- A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or one of [these Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) 
- Install your choice of Integrated Development Environment (IDE) software, such as Visual Studio, [Visual Studio Code](https://code.visualstudio.com/download), [Eclipse](https://www.eclipse.org/), or [IntelliJ](https://www.jetbrains.com/idea/).
- Download the latest version of [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
- [SQL Server Database Tooling](https://docs.microsoft.com/en-us/sql/azure-data-studio/download-azure-data-studio?view=sql-server-ver15) (Azure Data Studio/SSMS) 
- [SQL Server Data Tools](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-ver15) (including BI tools) – If using Visual Studio for IDE 

**Development Environment Configuration**

 None. 
 
**Links & Resources**  
Because you will be working in teams, a good overview of pair programming is useful. We recommend you read the following:

- [Pair Programming](https://www.agilealliance.org/glossary/pairing/)

**Post Learning Recommendations**  
- [Implement a Data Warehouse with Azure Synapse Analytics](https://docs.microsoft.com/en-us/learn/paths/implement-sql-data-warehouse/)
- [Large-Scale Data Processing with Azure Data Lake Storage Gen2](https://docs.microsoft.com/en-us/learn/paths/data-processing-with-azure-adls/)
- [Core Cloud Services - Azure data storage options](https://docs.microsoft.com/en-us/learn/modules/intro-to-data-in-azure/)
- [Azure for the Data Engineer](https://docs.microsoft.com/en-us/learn/paths/azure-for-the-data-engineer/)
- [Perform data engineering with Azure Databrick](https://docs.microsoft.com/en-us/learn/paths/data-engineer-azure-databricks/)
- [Architect a data platform in Azure](https://docs.microsoft.com/en-us/learn/paths/architect-data-platform/)


## Challenge Overview
**Challenge 1: Select and provision storage for an enterprise data lake**  
In this challenge, you will establish an enterprise data lake.  
**Learning objectives:**  
- Compare and contrast Azure storage offerings
- Provision the selected Azure storage service
 
**Challenge 2: Ingest data from cloud sources**  
In this challenge, you will extract the initial Southridge data from Azure SQL databases and a Cosmos DB collection.  
**Learning objectives:**  
- Orchestrate the ingestion of data from multiple cloud-based sources to a single cloud-based store
- Ensure the protection of specific customer data at all times leveraging the current technology set and solution architecture
 
**Challenge 3: Pull data from on-premises and establish source control**  
In this challenge, you will incorporate additional data sources into a new data lake. While the initial data was extracted from cloud based Azure SQL databases, the data from this challenge comes from on-premises data stores.  
**Learning objectives:**  
- Orchestrate the ingestion of data specifically from maintained “on-premises” solutions
- Implement a cloud-based source control repository for the developed solution
 
**Challenge 4: Transform and normalize data within the lake and establish branch policies**  
In this challenge, you will find (if you have not already!) that the data from these sources has a variety of data types and formats; it is up to the team to preprocess it to be consistent for downstream consumers.  
**Learning objectives:**  
- Transform data into a normalized schema for downstream consumption
- Create new policies to make certain all future changes leverage an appropriate review process
 
**Challenge 5: Populate a data warehouse and implement unit tests**  
In this challenge, you will need to fulfill the reporting needs of the business! A Power BI report will be provided to the team, but it’s up to them to create and populate the star schema to which it connects. The definition of the target schema is also supplied. From a DevOps perspective, the team will need to establish their approach to unit testing.  
**Learning objectives:**  
- Transform the data from the various source systems into a common data warehouse schema to support the generation of specific reports mandated by the business
- Orchestrate the dataflow into the data warehouse in an automated manner
- Build out unit tests across core components of the data pipeline
- Integrate automated testing into the code review process
 
**Challenge 6: Differential data loads and telemetry**  
In this challenge, you will need to address the ongoing needs of the business. Data from each new day of business needs to be added to the data lake, but it would be inefficient to repeatedly process all the historical data. You will need to implement an incremental load and establish a logging and telemetry solution by which you can monitor the amount of newly incorporated data.  
**Learning objectives:**  
- Modify the solution to include doing differential data loads as well as the original bulk load
- Automate data load and processing to run daily
- Implement rich telemetry into the dataflow and deployment pipelines
- Add error handling to raise pipeline issues in real-time
 
**Challenge 7: Automated deployment with validation and approval**

In this challenge, you will need to automate gated deployments of new and updated solutions.  
**Learning objectives:**  
- Operationalize the solution deployment process through automation
- Create and implement a testing environment
- Implement automated deployment processes and policies

## Value Proposition
- Modern cloud solution that results in higher reliability, scalability, and maintainability of large amounts of data.  
- Introduction to new data storage services to meet unique and multiple data stream needs


## Technical Scenarios
- Disparate data sources: ingest data in from multiple, differing data sources into one single location with one normalized schema for standardized downstream use  
- Security of data: protect data at all times while using ETL pipelines  
- DevOps: learn how to use a production pipeline to handle data layer  
