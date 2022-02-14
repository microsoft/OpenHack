param resourcesPrefix string
param location string = resourceGroup().location
param os string

var virtualNetworkName = '${resourcesPrefix}vnet'
var loadBalancerName = '${resourcesPrefix}lb'
var addressPrefix = '10.0.0.0/16'
var subnetAddressPrefix = '10.0.0.0/24'
var subnetName = 'vmssAdoAgentSubnet'

// https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/networkSecurityGroups?tabs=bicep
resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2021-05-01' = {
  name: '${resourcesPrefix}nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: (os == 'lnx' ? 'SSH' : 'RDP')
        properties: {
          priority: 1000
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: (os == 'lnx' ? '22' : '3389')
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.network/virtualnetworks?tabs=bicep
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
          networkSecurityGroup: {
            id: networkSecurityGroup.id
          }
        }
      }
    ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/publicIPAddresses?tabs=bicep
resource lbPublicIpAddress 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${resourcesPrefix}lbpip'
  location: location
  sku: {
    tier: 'Regional'
    name: 'Standard'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
  }
}

// https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/loadBalancers?tabs=bicep
resource loadBalancer 'Microsoft.Network/loadBalancers@2021-05-01' = {
  name: loadBalancerName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: lbPublicIpAddress.id
          }
        }
        name: 'loadBalancerFrontEnd01'
      }
    ]
    backendAddressPools: [
      {
        name: 'loadBalancerBackendPool01'
      }
    ]
    loadBalancingRules: [
      {
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'loadBalancerFrontEnd01')}'
          }
          backendAddressPool: {
            id: '${resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'loadBalancerBackendPool01')}'
          }
          // probe: {
          //   id: '${resourceId('Microsoft.Network/loadBalancers/probes', loadBalancerName, 'loadBalancerProbe01')}'
          // }
          protocol: 'Tcp'
          loadDistribution: 'Default'
          frontendPort: 80
          backendPort: 80
          idleTimeoutInMinutes: 5
          enableFloatingIP: false
          enableTcpReset: false
          disableOutboundSnat: false
        }
        name: 'loadBalancerRule01'
      }
    ]
    // probes: [
    //   {
    //     properties: {
    //       protocol: 'Tcp'
    //       port: 22
    //       intervalInSeconds: 5
    //       numberOfProbes: 2
    //     }
    //     name: 'loadBalancerProbe01'
    //   }
    // ]
    inboundNatPools: [
      {
        properties: {
          frontendIPConfiguration: {
            id: '${resourceId('Microsoft.Network/loadBalancers/frontendIPConfigurations', loadBalancerName, 'loadBalancerFrontEnd01')}'
          }
          protocol: 'Tcp'
          frontendPortRangeStart: 50000
          frontendPortRangeEnd: 50119
          backendPort: (os == 'lnx' ? 22 : 3389)
          enableFloatingIP: false
          enableTcpReset: false
          idleTimeoutInMinutes: 4
        }
        name: 'loadBalancerNatPool01'
      }
    ]
  }
}

output virtualNetworkSubnetId string = resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
output loadBalancerBackendAddressPoolId string = resourceId('Microsoft.Network/loadBalancers/backendAddressPools', loadBalancerName, 'loadBalancerBackendPool01')
output loadBalancerInboundNatPoolId string = resourceId('Microsoft.Network/loadBalancers/inboundNatPools', loadBalancerName, 'loadBalancerNatPool01')
