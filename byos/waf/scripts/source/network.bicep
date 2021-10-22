param region string
param vnetName string
param elbName string
param nsgName string
param web1vmDnslabel string
param web2vmDnslabel string
param worker1vmDnslabel string
param sqlsvr1vmDnslabel string
param elbDnsLabel string

resource vnet 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnetName
  location: region
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.10.0.0/16'
      ]
    }
    subnets: [ 
      {
        name: 'dmz'
        properties: {
          addressPrefix: '10.10.0.0/28'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'jobs'
        properties: {
          addressPrefix: '10.10.0.16/28'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: 'sql'
        properties: {
          addressPrefix: '10.10.0.32/27'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
  }
}

resource nsg 'Microsoft.Network/networkSecurityGroups@2020-11-01' = {
  name: nsgName
  location: region
  properties: {
    securityRules: [
      {
        name: 'AllowAll'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
    ]
  }
}

resource web1vmPIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'web1ip'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'   
    dnsSettings: {
      domainNameLabel: web1vmDnslabel
    }    
  }
}

resource web1vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'web1nic'
  location: region
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    vnetEncryptionSupported: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/dmz'
          }
          privateIPAddress: '10.10.0.4'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: web1vmPIP.id
          }
        }
      }
    ]
  }
}

resource web2vmPIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'web2ip'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'  
    dnsSettings: {
      domainNameLabel: web2vmDnslabel
    }     
  }
}

resource web2vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'web2nic'
  location: region
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    vnetEncryptionSupported: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/dmz'
          }
          privateIPAddress: '10.10.0.5'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: web2vmPIP.id
          }
        }
      }
    ]
  }
}

resource worker1vmPIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'worker1ip'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: worker1vmDnslabel
    }  
  }
}

resource worker1vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'worker1nic'
  location: region
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    vnetEncryptionSupported: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/jobs'
          }
          privateIPAddress: '10.10.0.20'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: worker1vmPIP.id
          }
        }
      }
    ]
  }
}

resource sqlsvr1vmPIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'sqlsvr1ip'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: sqlsvr1vmDnslabel
    }  
  }
}

resource sqlsvr1vmNic 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'sqlsvr1nic'
  location: region
  properties: {
    networkSecurityGroup: {
      id: nsg.id
    }
    vnetEncryptionSupported: false
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: '${vnet.id}/subnets/sql'
          }
          privateIPAddress: '10.10.0.36'
          privateIPAllocationMethod: 'Static'
          privateIPAddressVersion: 'IPv4'
          publicIPAddress: {
            id: sqlsvr1vmPIP.id
          }
        }
      }
    ]
  }
}

resource elbPIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'elbip'
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: elbDnsLabel
    }  
  }
}

resource elb 'Microsoft.Network/loadBalancers@2020-11-01' = {
  name: elbName
  location: region
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'webapp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: elbPIP.id
          }
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'webapp'
      }
    ]
    loadBalancingRules: [
      {
        name: 'webapp'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/loadbalancers/frontendIPConfigurations', elbName, 'webapp')
          }
          frontendPort: 80
          backendPort: 80
          allowBackendPortConflict: false
          enableDestinationServiceEndpoint: false
          enableFloatingIP: false
          idleTimeoutInMinutes: 4
          protocol: 'Tcp'
          enableTcpReset: false
          loadDistribution: 'SourceIP'
          disableOutboundSnat: true
          backendAddressPool: {
            id: resourceId('Microsoft.Network/loadbalancers/backendAddressPools', elbName, 'webapp')
          }
          probe: {
            id: resourceId('Microsoft.Network/loadbalancers/probes', elbName, 'webappprobe')
          }
        }
      }    
    ]
    probes: [
      {
        name: 'webappprobe'
        properties: {
          protocol: 'Http'
          port: 80
          requestPath: '/'
          intervalInSeconds: 5
          numberOfProbes: 2
        }
      }
    ]
  }
}

resource elbBackendPool 'Microsoft.Network/loadBalancers/backendAddressPools@2020-11-01' = {
  name: '${elbName}/webapp'
  dependsOn: [
    elb
  ]
  properties: {
    loadBalancerBackendAddresses: [
      {
        name: 'web1'
        properties: {
          virtualNetwork: {
            id: vnet.id
          }
          ipAddress: web1vmNic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
      {
        name: 'web2'
        properties: {
          virtualNetwork: {
            id: vnet.id
          }
          ipAddress: web2vmNic.properties.ipConfigurations[0].properties.privateIPAddress
        }
      }
    ]
  }
}

output web1vmNicId string = web1vmNic.id
output web2vmNicId string = web2vmNic.id
output worker1vmNicId string = worker1vmNic.id
output sqlsvr1vmNicId string = sqlsvr1vmNic.id
