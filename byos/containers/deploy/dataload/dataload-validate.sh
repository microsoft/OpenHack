#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

randStr=$(openssl rand -base64 6 | tr -d "=+/" | tr '[:upper:]' '[:lower:]')
sqlServerName="$(echo "sqlserver${randStr}")"
sqlServerUsername="sqladmin${randStr}"
sqlServerPassword="$(openssl rand -base64 15 | tr -d "=+/")" 
sqlDBName="mydrivingDB"
dataLoadImage="$1"
resourceGroupLocation="$2"
resourceGroupName="dataload-$3"
imageRegistryUsername="$4"
imageRegistryPassword="$5"
registryName="$6"

az group create -l $resourceGroupLocation -n $resourceGroupName

az sql server create -l $resourceGroupLocation -g $resourceGroupName -n $sqlServerName -u $sqlServerUsername -p $sqlServerPassword

if [ $? == 0 ];
then
    echo "SQL Server created successfully."
    echo "Adding firewall rule to SQL server..."
    az sql server firewall-rule create --resource-group $resourceGroupName --server $sqlServerName -n "Allow Access To Azure Services" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0
    
    if [ $? == 0 ];
    then
        echo "Firewall rule added successfully to SQL server."
    else
        echo "Failed to add firewall rule to SQL server."
        exit 1
    fi

    # Create Azure SQL DB
    echo "Creating Azure SQL DB..."
    az sql db create -g $resourceGroupName -s $sqlServerName -n $sqlDBName

    if [ $? == 0 ];
    then
        echo "SQL database created successfully."
        az container create -g $resourceGroupName --name dataload --image $dataLoadImage --registry-username $imageRegistryUsername --registry-password $imageRegistryPassword --registry-login-server $registryName --restart-policy Never --secure-environment-variables SQLFQDN=$sqlServerName.database.windows.net SQLUSER=$sqlServerUsername SQLPASS=$sqlServerPassword SQLDB=$sqlDBName
        logs=$(az container logs -g $resourceGroupName --name dataload)
        if [[ logs =~ "BCP copy in failed" ]]; then
            echo "Failed to load data into database."
        else
            echo "Successfully loaded data into database."
        fi
    else
        echo "Failed to create SQL database."
        exit 1
    fi
else
    echo "Failed to create SQL Server."
    exit 1
fi