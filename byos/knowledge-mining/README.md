# OpenHack Containers Overview

## Overview
**This OpenHack enables participants to** add intelligent search capabilities to their applications and services, leveraging artificial intelligence to extract meaningful results from data. 

**This OpenHack simulates a real-world scenario** where a travel company needs to uncover data locked up in documents and withdraw insights from that data to make key business decisions. 
**During the “hacking”, participants will focus on:**  
1. Exploring ways in which Azure Search can be used as the core of a search solution.
2. Enriching the search solution through integration with Cognitive Services, Azure Machine Learning, and custom code. 

**By the end of the OpenHack, participants will have built out a technical solution** that is a complete Azure machine learning-based intelligent search infrastructure that can interpret vast quantities of diverse data (i.e. documents, scanned images, and other digital artifacts).


## Technologies
Azure Cognitive Services, Azure Functions, Question Answering, Language Understanding Service, Form Recognizer, Azure Machine Learning
## Knowledge Prerequisites
**Knowledge Prerequisites** 
To be successful and get the most out of this OpenHack, it is highly recommended that participants have previous experience with either C#, JavaScript, or Python coding language and are familiar with the technologies listed above. Participants should have a basic understanding of how different services interact through APIs (Application Programing Interfaces), including REST/JSON interfaces.  
Required knowledge of [Azure fundamentals](https://docs.microsoft.com/en-us/learn/paths/azure-fundamentals/). 

**Language-Specific Prerequisites**  
- Hands-on coding is required in at least one of the following programing languages: C#, JavaScript/Node.js, or Python.

**Tooling Prerequisites**  
To avoid any delays with downloading or installing tooling, have the following ready to go ahead of the OpenHack: 
  - A modern laptop running Windows 10 (1703 or higher), Mac OSX (10.12 or higher), or one of [these Ubuntu versions](https://github.com/Azure/azure-functions-core-tools#linux) 
  - Install your choice of Integrated Development Environment (IDE) software, such as Visual Studio, [Visual Studio Code](https://code.visualstudio.com/download), [Eclipse](https://www.eclipse.org/), or [IntelliJ](https://www.jetbrains.com/idea/). 
- After installing Visual Studio Code, install the following language-specific extensions for the language you plan to use:
- C#
    - [.NET Core SDK](https://dotnet.microsoft.com/download)
    - [C# Extension for Visual Studio Code ](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.csharp)
- JavaScript
    - [Node.js](https://nodejs.org/en/)
- Python
    - [Python Extension for Visual Studio Code](https://marketplace.visualstudio.com/items?itemName=ms-python.python) 
- After installing the language-specific extensions, install the [Azure Functions](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-azurefunctions) extension. You will use this in some of the later challenges.
- Most of the operations to create and modify Azure Search entities involve submitting JSON requests to a REST interface. You can write code in your preferred language to do this, or you can use [Postman](https://www.postman.com/downloads/) to create and submit collections of REST requests.

**Development Environment Configuration**
- None.

**Links & Resources**  
- [Azure Cognitive Search documentation](https://docs.microsoft.com/azure/search/)

**Post Learning Recommendations**  
- For a more directed learning experience, complete the [Implement knowledge mining with Azure Cognitive Searc](https://docs.microsoft.com/learn/paths/implement-knowledge-mining-azure-cognitive-search/)h learning path on Microsoft Learn.
- Consider completing the [Microsoft Certified AI Engineer Associate certification](https://docs.microsoft.com/learn/certifications/azure-ai-engineer/).

## Challenge Overview
**Challenge 1: A Question of Knowledge**  
In this challenge, you will use Microsoft Question Answering cognitive service to build and publish a knowledge base. 
- Learning objectives:
    - Create a question answering knowledge base that includes suitable question and answer pairs
    - Write code that uses the REST API to query the knowledge base
    
**Challenge 2: The Search Begins**  
In this challenge, you will create a datasource, index, and indexer and demonstrate code that successfully retrieves the information.
- Learning objectives:
    - Create an Azure Search Index
    - Use the SDK or REST API to submit a range of search queries using both simple and full syntax
    
**Challenge 3: Expanding the Search**  
In this challenge, you will update the index and demonstrate code that successfully retrieves information. 
- Learning objectives:
    - Add built-in cognitive skills to an Azure Search index to return:
        - Key Phrases  
        - Entities (including links)  
        - Sentiment (especially reviews)  
        
**Challenge 4: Getting the Full Picture**  
In this challenge, you will use the OCR skill to expand the index to extract AI-generated descriptions of images embedded in documents. 
- Learning objectives:
    - Add built-in cognitive skills to an Azure Search index to return:
        - Image Descriptions and Tags
        - OCR extracted Text
        
**Challenge 5: What is the Frequency?**  
In this challenge, you will create a web API custom skill for your Azure Search index.
- Learning objectives:
    - Create a custom skill to find the top ten most frequent words
    - Incorporate your custom skill into your web content index
    
**Challenge 6: The Search for Relevance**  
In this challenge, you will create return search results based on synonyms and display suggestions and autocomplete options. 
- Learning objectives:
    - Add Synonyms to Azure Search index to ensure relevant results
    - Implement query suggestions / autocomplete
    - Add scoring profiles that boost documents in results

**Challenge 7: Knowledge preservation**  
In this challenge, you will modify the index skillset to generate knowledge store assets. Browse the blobs and tables in the knowledge store using the Storage Explorer interface. 
- Learning objectives:
    - Implement knowledge stores.
    
**Challenge 8: Finding Your Form**
In this challenge, you will train a Form Recognizer model and integrate into a new Azure Search index. 
- Learning objectives:
    - Create a custom skill that calls the Forms Understanding Service
    
**Challenge 9: Use Your Intelligence**
In this challenge, you will publish a machine learning model as a web service to predict claim probability. 
- Learning objectives:
    - Build a custom skill that consumes a custom machine learning model

## Value Proposition
- This OpenHack provides a real-world context of Azure services for knowledge mining with Azure Search.
- Learn common knowledge mining and intelligent search scenarios.
- AI-Powered Knowledge Mining helps businesses make better decisions through more robust data extraction and analysis.
- Improved search functionality to decrease time-to-find relevant data.


## Technical Scenarios
- Search – Improving the ability to ingest data from various sources, intelligently sift through that data using core Azure AI services like Azure Search and Cog Services, and then analyze that data
- Data modeling – Create custom ML models that learn from data and continuously improve search
