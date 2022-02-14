targetScope = 'subscription'

param uniquer string = toLower(substring(uniqueString(utcNow()),0, 5))
param location string = deployment().location
param resourcesPrefix string = ''
param spPrincipalId string

var namePrefix = 'devopsoh'
var resourcesPrefixCalculated = empty(resourcesPrefix) ? '${namePrefix}${uniquer}' : resourcesPrefix
var resourceGroupName = '${resourcesPrefixCalculated}staterg'

module stateResourceGroup './azureResourceGroup.bicep' = {
  name: '${resourcesPrefixCalculated}-resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

module stateStorageAccount './azureStorageAccount.bicep' = {
  name: '${resourcesPrefixCalculated}-storageAccountDeployment'
  params: {
    storageAccountName: '${resourcesPrefixCalculated}statest'
    spPrincipalId: spPrincipalId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    stateResourceGroup
  ]
}
