# OpenHack NoSQL Overview

## Overview
Microsoft’s OpenHack series is a three-day immersive, hands-on, challenge-driven hack that brings together developers from across the ecosystem and Microsoft to tackle scenarios influenced by common, real-world problems using Microsoft platform capabilities and other industry leading technologies.

Organizations are moving to the cloud in record numbers. Part of the driving force behind these cloud migrations is a desire to modernize data platforms to accommodate an ever-increasing amount of data coming in from mobile applications, social media and IoT devices as well as a desire to capitalize on the global capacity of hyper-scale cloud providers such as Azure. The OpenHack NoSQL event will challenge developers and data professionals to migrate a legacy database application to the cloud and modernize it to accommodate new business features. They will continue the path by scaling out their solution for global availability and developing new functionality to provide additional insights to the business and value to customers.


## Technologies
Cosmos DB, Azure SQL Database, Azure Data Factory, Azure Functions, Azure Event Hubs, Azure Stream Analytics, Power BI, and Azure Cognitive Search.

## Knowledge Prerequisites
**Knowledge Prerequisites**  
To be successful and get the most out of this OpenHack, participants should have familiarity with database concepts such as data modeling, partitioning, denormalization, and indexing. Prior experience with NoSQL databases and familiarity with relational data structures is helpful, but not required. 

Required knowledge of [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/azure-fundamentals/). 

**Language-Specific Prerequisites**
- Recommended that participants have previous experience with knowledge of programing languages including C#, JavaScript, Node.JS or Java.

**Tooling Prerequisites**  
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
  - A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or one of [these Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) 
  - Install your choice of Integrated Development Environment (IDE) software, such as Visual Studio, [Visual Studio Code](https://code.visualstudio.com/download), [Eclipse](https://www.eclipse.org/), or [IntelliJ](https://www.jetbrains.com/idea/). 
  
**Development Environment Configuration**  
- [.NET Core (latest version, 3.1) ](https://dotnet.microsoft.com/download)-- required 
- [.NET Framework (latest version, 4.8)](https://dotnet.microsoft.com/download) -- optional 

**Links & Resources**
We strongly recommend watching the below videos (from Ignite 2019) to prepare for this NoSQL OpenHack: (Note: Updated to YouTube links on 2020-Sep-10 because the links to MyIgnite no longer worked.)
- [Data modeling in NoSQL databases (BRK3015)](https://www.youtube.com/watch?v=UJtqZ5oWG4Q)
  - https://www.youtube.com/watch?v=UJtqZ5oWG4Q 
- [Building event-driven apps with NoSQL databases (BRK3016)](https://www.youtube.com/watch?v=EPmnZvogEUQ )
  - https://www.youtube.com/watch?v=EPmnZvogEUQ 

## Challenge Overview
**Challenge 1: To the cloud** 
In this challenge, you will provision the NoSQL database.
Learning objectives:
- Provisioning a NoSQL database in Azure, using the following characteristics: 
o	Enables a simplified process for scaling up and down
o	Supports the event sourcing pattern where changes to the data store trigger events that can be processed by any number of listening components in near real-time
o	Supports a flexible schema with a multi-region, global distribution
- Store any arbitrary record in the database



**Challenge 2: Migrating the database to the cloud** 
In this challenge, you will migrate all data to the new database.
Learning objectives:
- Create a repeatable process to migrate from the supplied SQL database to the selected NoSQL database, validate the migration through queries, and explain to the coach how the database can be scaled. 

**Challenge 3: Optimize NoSQL design**
In this challenge, you will implement optimizations and demonstrate an improvement in query performance, and/or cost per query. 
Learning objectives:
- Estimate the cost per query for reads and writes, as well as query performance
- Use best practices for optimizing the database after evaluating common queries and workloads, then show a measurable improvement after optimization is complete
- Attendees may need to migrate their data once again
Challenge 4: Events are the center of our universe
In this challenge, you will add new features to the solution to support the event sourcing pattern and create a report dashboard. 
Learning objectives:
- Create a caching layer for a subset of the data
- Use the event sourcing pattern on order data that flows into the database
- Use these events to create materialized views, real-time dashboards, and cache invalidation

Challenge 5: Improving the search experience
In this challenge, you will implement full-text searching capabilities by creating an index on the title and description fields and add other filters to help users quickly narrow the results. 
Learning objectives:
- Enable full-text, fuzzy, and faceted searching capabilities on the database
Challenge 6: Taking over the world (MUAHAHAHA)
In this challenge, you will create a new node or replica of the NoSQL data store within a new Azure region.
Learning objectives:
- Add the NoSQL database to a new region with full replication between both regions
- Help the customer meet data durability and low latency objectives



## Value Proposition
- Gain experience migrating from a relational database to NoSQL, using tools to automate the process  
- Learn how to optimize the NoSQL database through modeling, denormalization, indexing, and partitioning, given a set of customer requirements and query patterns  
- Enable app modernization through a scalable, distributed, event-based data pipeline, enabled by a flexible NoSQL data store and complimentary Azure services  
- Reduce latency and increase availability and customer reach, through global distribution of the NoSQL database


## Technical Scenarios
- Migration to NoSQL – given an existing web application and SQL database, initially perform a raw migration to a Cosmos DB or other NoSQL database in Azure, creating a repeatable process with various tools and services  
- NoSQL data modeling and optimization – Evaluating a relational data store, then adapting the schema to a data model, optimized for both write-heavy and read-heavy workloads in NoSQL. Optimization includes combining models as necessary within the same collections, denormalization and embedding, implementing an appropriate indexing strategy for the workloads and query patterns, and selecting an optimal partition strategy  
- Event sourcing – Reacting to data events, such as inserts and updates, enabling scenarios such as populating real-time dashboards, creating materialized views (aggregation), and automatic cache invalidation  
- Advanced visualizations – UI components that show both real-time and batch data with little to no impact to NoSQL database performance  
- Expanding search capabilities – Reaching beyond native indexing and search capabilities provided by the NoSQL database, through an external search service that enables full-text, fuzzy (can handle misspellings), and faceted search against the data catalog  
- Global reach – Adding high availability and low latency by replicating data across geographical regions, bringing data closer to users and deployed services
