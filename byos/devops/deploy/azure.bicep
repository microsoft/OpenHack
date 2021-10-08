targetScope = 'subscription'

param uniquer string
param location string = deployment().location
param spPrincipalId string

var resourceGroupName = '${uniquer}staterg'

module stateResourceGroup './azureResourceGroup.bicep' = {
  name: '${deployment().name}-resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

module stateStorageAccount './azureStorageAccounts.bicep' = {
  name: 'storageAccountpDeployment'
  params: {
    storageAccountName: '${uniquer}statest'
    spPrincipalId: spPrincipalId
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    stateResourceGroup
  ]
}
