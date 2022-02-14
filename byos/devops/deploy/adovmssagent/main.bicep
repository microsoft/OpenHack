targetScope = 'subscription'

param uniquer string = toLower(substring(uniqueString(utcNow()), 0, 5))
param location string = deployment().location
param resourcesPrefix string = ''

@allowed([
  'lnx'
  'win'
])
param os string = 'lnx'

@secure()
param adminPasswordOrKey string = ''

var namePrefix = 'ado${os}'
var resourcesPrefixCalculated = empty(resourcesPrefix) ? '${namePrefix}${uniquer}' : resourcesPrefix
var resourceGroupName = '${resourcesPrefixCalculated}rg'

module vmssResourceGroup './modules/resourceGroup.bicep' = {
  name: '${resourcesPrefixCalculated}-resourceGroupDeployment'
  params: {
    resourceGroupName: resourceGroupName
    location: location
  }
}

module vmssNetwork './modules/network.bicep' = {
  name: '${resourcesPrefixCalculated}-networkDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
    os: os
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    vmssResourceGroup
  ]
}

module vmssCompute './modules/vmss.bicep' = {
  name: '${resourcesPrefixCalculated}-computeDeployment'
  params: {
    resourcesPrefix: resourcesPrefixCalculated
    loadBalancerBackendAddressPoolId: vmssNetwork.outputs.loadBalancerBackendAddressPoolId
    loadBalancerInboundNatPoolId: vmssNetwork.outputs.loadBalancerInboundNatPoolId
    virtualNetworkSubnetId: vmssNetwork.outputs.virtualNetworkSubnetId
    os: os
    adminPasswordOrKey: adminPasswordOrKey
  }
  scope: resourceGroup(resourceGroupName)
  dependsOn: [
    vmssNetwork
  ]
}
