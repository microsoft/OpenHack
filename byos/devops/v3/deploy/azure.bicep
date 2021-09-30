targetScope = 'subscription'

param uniquer string
param location string = deployment().location
param spPrincipalId string

var resourceGroupName = '${uniquer}staterg'

module supportResourceGroup './azureResourceGroup.bicep' = {
  name: 'resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

module supportStorageAccount './azureStorageAccounts.bicep' = {
  name: 'storageAccountpDeployment'
  params: {
    storageAccountName: '${uniquer}statest'
    location: location
    spPrincipalId: spPrincipalId
  }
  scope: resourceGroup(resourceGroupName)
}
