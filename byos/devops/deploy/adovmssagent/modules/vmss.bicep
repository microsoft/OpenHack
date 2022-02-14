param resourcesPrefix string
param location string = resourceGroup().location
param loadBalancerBackendAddressPoolId string
param loadBalancerInboundNatPoolId string
param virtualNetworkSubnetId string
param os string

@secure()
param adminPasswordOrKey string = ''

var adminUsername = 'azureuser'

var authenticationType = (os == 'lnx' ? 'sshPublicKey' : 'password')
var linuxImageReference = {
  publisher: 'Canonical'
  offer: 'UbuntuServer'
  sku: '18.04-LTS'
  version: 'latest'
}
var windowsImageReference = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2019-Datacenter'
  version: 'latest'
}
var windowsConfiguration = {
  timeZone: 'Pacific Standard Time'
}
var linuxConfiguration = {
  disablePasswordAuthentication: true
  provisionVMAgent: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${adminUsername}/.ssh/authorized_keys'
        keyData: adminPasswordOrKey
      }
    ]
  }
}

var imageReference = (os == 'lnx' ? linuxImageReference : windowsImageReference)

// https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/virtualmachinescalesets?tabs=bicep
resource symbolicname 'Microsoft.Compute/virtualMachineScaleSets@2021-07-01' = {
  name: '${resourcesPrefix}vmss'
  location: location
  sku: {
    capacity: 2
    name: 'Standard_D2s_v3'
    tier: 'Standard'
  }
  properties: {
    doNotRunExtensionsOnOverprovisionedVMs: false
    overprovision: false
    platformFaultDomainCount: 1
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
      rollingUpgradePolicy: {
        maxBatchInstancePercent: 20
        maxUnhealthyInstancePercent: 20
        maxUnhealthyUpgradedInstancePercent: 20
        pauseTimeBetweenBatches: 'PT0S'
        prioritizeUnhealthyInstances: true
      }
    }
    virtualMachineProfile: {
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: '${resourcesPrefix}vmssnic'
            properties: {
              enableAcceleratedNetworking: false
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: '${resourcesPrefix}vmssipconfig'
                  properties: {
                    loadBalancerBackendAddressPools: [
                      {
                        id: loadBalancerBackendAddressPoolId
                      }
                    ]
                    loadBalancerInboundNatPools: [
                      {
                        id: loadBalancerInboundNatPoolId
                      }
                    ]
                    privateIPAddressVersion: 'IPv4'
                    subnet: {
                      id: virtualNetworkSubnetId
                    }
                  }
                }
              ]
              primary: true
            }
          }
        ]
      }
      osProfile: {
        adminPassword: (authenticationType == 'password' ? adminPasswordOrKey : null)
        adminUsername: adminUsername
        computerNamePrefix: toLower(substring(resourcesPrefix, 0, 9))
        linuxConfiguration: (os == 'lnx' && authenticationType == 'sshPublicKey' ? linuxConfiguration : null)
        windowsConfiguration: (os == 'win' ? windowsConfiguration : null)
      }
      diagnosticsProfile: {
        bootDiagnostics: {
          enabled: true
        }
      }
      storageProfile: {
        imageReference: imageReference
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
        }
      }
    }
  }
}
