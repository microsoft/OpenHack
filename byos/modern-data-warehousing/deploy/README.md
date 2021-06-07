# Modern Data Warehousing OpenHack Lab BYOS

## Quickstart

1. Please review the file `deployment.md` to see the specific deployment instructions for running the setup process in your own subscription.  

## Overview

The deployment of the Modern Data Warehousing OpenHack Lab environment can take around 20-30 minutes to complete.

## After Deployment

Once deployment is completed, you should validate that you have the appropriate resources for the openhack installed and configured.

The deployment of the Modern Data Warehousing OpenHack Lab environment includes the following for each team.

### Southridge Video Resources  

1) Two Azure SQL DBs in a single logical server
    * Validate databases exist and have data  
        * CloudSales
        * CloudStreaming

2) A Cosmos DB account with a single collection for the movie catalog
    * Use the data explorer to ensure data was loaded as expected.

### Fourth Coffee Resources

1) A VM with a directory of CSV data

### VanArsdel, Ltd. Resources

1) A VM with a SQL DB
    * Database is OnPremesisRentals
    * Database is successfully restored with data