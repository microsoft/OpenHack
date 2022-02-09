// TODO
// https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/scale-set-agents?view=azure-devops

param vmssAgentspoolVnetName string 
param vmssAgentspoolName string 

param location string 

param adminUsername string
// SSH Key or password for the Virtual Machine. SSH key is recommended.
//@secure()
param adminPasswordOrKey string 

resource virtualNetworks_vmssagentspoolVNET_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vmssAgentspoolVnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'vmssagentspoolSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource virtualMachineScaleSets_vmssagentspool_name_resource 'Microsoft.Compute/virtualMachineScaleSets@2021-07-01' = {
  name: vmssAgentspoolName
  location: location
  sku: {
    name: 'Standard_D2_v3'
    tier: 'Standard'
    capacity: 2
  }
  properties: {
    singlePlacementGroup: false
    upgradePolicy: {
      mode: 'Manual'
      rollingUpgradePolicy: {
        maxBatchInstancePercent: 20
        maxUnhealthyInstancePercent: 20
        maxUnhealthyUpgradedInstancePercent: 20
        pauseTimeBetweenBatches: 'PT0S'
      }
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vmssa0413'
        adminUsername: adminUsername
        linuxConfiguration: {
          disablePasswordAuthentication: true
          ssh: {
            publicKeys: [
              {
                path: '/home/${adminUsername}/.ssh/authorized_keys'
                keyData: adminPasswordOrKey
              }
            ]
          }
          provisionVMAgent: true
        }
        secrets: []
      }
      storageProfile: {
        osDisk: {
          osType: 'Linux'
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'StandardSSD_LRS'
          }
          diskSizeGB: 30
        }
        imageReference: {
          publisher: 'Canonical'
          offer: 'UbuntuServer'
          sku: '18.04-LTS'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vmssa0413Nic'
            properties: {
              primary: true
              enableAcceleratedNetworking: false
              dnsSettings: {
                dnsServers: []
              }
              enableIPForwarding: false
              ipConfigurations: [
                {
                  name: 'vmssa0413IPConfig'
                  properties: {
                    subnet: {
                      id: resourceId('Microsoft.Network/virtualNetworks/subnets', vmssAgentspoolVnetName, '${vmssAgentspoolName}Subnet')
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
    }
    overprovision: false
    doNotRunExtensionsOnOverprovisionedVMs: false
    platformFaultDomainCount: 1
  }
  dependsOn: [
    virtualNetworks_vmssagentspoolVNET_name_vmssagentspoolSubnet
  ]
}

resource virtualNetworks_vmssagentspoolVNET_name_vmssagentspoolSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: virtualNetworks_vmssagentspoolVNET_name_resource
  name: 'vmssagentspoolSubnet'
  properties: {
    addressPrefix: '10.0.0.0/24'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource virtualMachineScaleSets_vmssagentspool_name_0 'Microsoft.Compute/virtualMachineScaleSets/virtualMachines@2021-07-01' = {
  parent: virtualMachineScaleSets_vmssagentspool_name_resource
  name: '0'
  location: location
  properties: {
    networkProfileConfiguration: {
      networkInterfaceConfigurations: [
        {
          name: 'vmssa0413Nic'
          properties: {
            primary: true
            enableAcceleratedNetworking: false
            dnsSettings: {
              dnsServers: []
            }
            enableIPForwarding: false
            ipConfigurations: [
              {
                name: 'vmssa0413IPConfig'
                properties: {
                  subnet: {
                    id: virtualNetworks_vmssagentspoolVNET_name_vmssagentspoolSubnet.id
                  }
                  privateIPAddressVersion: 'IPv4'
                }
              }
            ]
          }
        }
      ]
    }
    hardwareProfile: {}
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'vmssa0413000000'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPasswordOrKey
            }
          ]
        }
        provisionVMAgent: true
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: '${resourceId('Microsoft.Compute/virtualMachineScaleSets/virtualMachines', vmssAgentspoolName, '0')}/networkInterfaces/vmssa0413Nic' 
        }
      ]
    }
  }
}

resource virtualMachineScaleSets_vmssagentspool_name_1 'Microsoft.Compute/virtualMachineScaleSets/virtualMachines@2021-07-01' = {
  parent: virtualMachineScaleSets_vmssagentspool_name_resource
  name: '1'
  location: location
  properties: {
    networkProfileConfiguration: {
      networkInterfaceConfigurations: [
        {
          name: 'vmssa0413Nic'
          properties: {
            primary: true
            enableAcceleratedNetworking: false
            dnsSettings: {
              dnsServers: []
            }
            enableIPForwarding: false
            ipConfigurations: [
              {
                name: 'vmssa0413IPConfig'
                properties: {
                  subnet: {
                    id: virtualNetworks_vmssagentspoolVNET_name_vmssagentspoolSubnet.id
                  }
                  privateIPAddressVersion: 'IPv4'
                }
              }
            ]
          }
        }
      ]
    }
    hardwareProfile: {}
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        osType: 'Linux'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 30
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'vmssa0413000001'
      adminUsername: adminUsername
      linuxConfiguration: {
        disablePasswordAuthentication: true
        ssh: {
          publicKeys: [
            {
              path: '/home/${adminUsername}/.ssh/authorized_keys'
              keyData: adminPasswordOrKey
            }
          ]
        }
        provisionVMAgent: true
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkInterfaces: [
        {    
             id: '${resourceId('Microsoft.Compute/virtualMachineScaleSets/virtualMachines', vmssAgentspoolName, '1')}/networkInterfaces/vmssa0413Nic'
        }
      ]
    }
  }
}
