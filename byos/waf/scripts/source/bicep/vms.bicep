param region string
param web1vmNicId string
param web2vmNicId string 
param worker1vmNicId string 
param sqlsvr1vmNicId string 
param adminUsername string
@secure()
param adminPassword string
param sqlAdminUsername string
@secure()
param sqlAdminPassword string

resource web1vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'web1'
  location: region
  properties: {
    osProfile: {
      computerName: 'web1'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_F8s_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: web1vmNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource web1vmFiles 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'web1/DownloadWebFiles'
  location: region
  dependsOn: [
    web1vm
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/Portal.Web.zip\' -OutFile Portal.Web.zip && powershell Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/Portal.Api.zip\' -OutFile Portal.Api.zip && powershell Expand-Archive -Path Portal.Web.zip -DestinationPath \'D:\\web\' && powershell Expand-Archive -Path Portal.Api.zip -DestinationPath \'D:\\api\''
    }
  }
}

resource web1vmIIS 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'web1/InstallWebServer'
  location: region
  dependsOn: [
    web1vm
    web1vmFiles
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ConfigurationFunction: 'WindowsWebServer.ps1\\WindowsWebServer'
      ModulesUrl: 'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/DSC/WindowsWebServer.zip'
      Properties: {}
    }
    protectedSettings: {}
  }
}

resource web2vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'web2'
  location: region
  properties: {
    osProfile: {
      computerName: 'web2'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_F8s_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: web2vmNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource web2vmFiles 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'web2/DownloadWebFiles'
  location: region
  dependsOn: [
    web1vm
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/Portal.Web.zip\' -OutFile Portal.Web.zip && powershell Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/Portal.Api.zip\' -OutFile Portal.Api.zip && powershell Expand-Archive -Path Portal.Web.zip -DestinationPath \'D:\\web\' && powershell Expand-Archive -Path Portal.Api.zip -DestinationPath \'D:\\api\''
    }
  }
}

resource web2vmIIS 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'web2/InstallWebServer'
  location: region
  dependsOn: [
    web2vm
    web2vmFiles
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ConfigurationFunction: 'WindowsWebServer.ps1\\WindowsWebServer'
      ModulesUrl: 'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/DSC/WindowsWebServer.zip'
      Properties: {}
    }
    protectedSettings: {}
  }
}

resource worker1vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'worker1'
  location: region
  properties: {
    osProfile: {
      computerName: 'worker1'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    hardwareProfile: {
      vmSize: 'Standard_F8s_v2'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: worker1vmNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource worker1vmFiles 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'worker1/DownloadWebFiles'
  location: region
  dependsOn: [
    web1vm
  ]
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.7'
    autoUpgradeMinorVersion: true
    settings: {
      commandToExecute: 'powershell.exe Invoke-WebRequest -Uri \'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/Processor.zip\' -OutFile Processor.zip && powershell Expand-Archive -Path Processor.zip -DestinationPath \'D:\\jobs\''
    }
  }
}

resource worker1vmTasks 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'worker1/CreateScheduledTasks'
  location: region
  dependsOn: [
    worker1vm
    worker1vmFiles
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ConfigurationFunction: 'WorkerServer.ps1\\WorkerServer'
      ModulesUrl: 'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/DSC/WorkerServer.zip'
      Properties: {}
    }
    protectedSettings: {}
  }
}

resource sqlsvr1vmDataDisk0 'Microsoft.Compute/disks@2020-12-01' = {
  name: 'sqlsvr1_DataDisk_0'
  location: region
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    diskSizeGB: 1024
    creationData: {
      createOption:'Empty'
    }
  }
}

resource sqlsvr1vmDataDisk1 'Microsoft.Compute/disks@2020-12-01' = {
  name: 'sqlsvr1_DataDisk_1'
  location: region
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    diskSizeGB: 1024
    creationData: {
      createOption:'Empty'
    }
  }
}

resource sqlsvr1vm 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: 'sqlsvr1'
  location: region
  properties: {
    osProfile: {
      computerName: 'sqlsvr1'
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: false
        patchSettings: {
          patchMode: 'Manual'
          enableHotpatching: false
        }
      }
      allowExtensionOperations: true
    }
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'microsoftsqlserver'
        offer: 'sql2014sp3-ws2012r2'
        sku: 'web'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
        diskSizeGB: 127
      }
      dataDisks: [
        {
          name: 'sqlsvr1_DataDisk_0'
          createOption: 'Attach'
          caching: 'ReadOnly'
          lun: 0
          writeAcceleratorEnabled: false
          managedDisk: {
            id: sqlsvr1vmDataDisk0.id
          }
        }
        {
          name: 'sqlsvr1_DataDisk_1'
          createOption: 'Attach'
          caching: 'None'
          lun: 1
          writeAcceleratorEnabled: false
          managedDisk: {
            id: sqlsvr1vmDataDisk1.id
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          properties: {
            primary: true
          }
          id: sqlsvr1vmNicId
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource sqlsvr1sql 'Microsoft.SqlVirtualMachine/sqlVirtualMachines@2017-03-01-preview' = {
  name: 'sqlsvr1'
  location: region
  dependsOn: [
    sqlsvr1vm
  ]
  properties: {
    virtualMachineResourceId: sqlsvr1vm.id
    sqlManagement: 'Full'
    sqlServerLicenseType: 'PAYG'
    autoPatchingSettings: {
      enable: true
      dayOfWeek: 'Sunday'
      maintenanceWindowStartingHour: 15
      maintenanceWindowDuration: 120
    }
    keyVaultCredentialSettings: {
      enable: false
      credentialName: ''
    }
    storageConfigurationSettings: {
      diskConfigurationType: 'NEW'
      storageWorkloadType: 'OLTP'
      sqlDataSettings: {
        luns: [
          0
        ]
        defaultFilePath: 'f:\\Data'
      }
      sqlLogSettings: {
        luns: [
          1
        ]
        defaultFilePath: 'g:\\Logs'
      }
      sqlTempDbSettings: {
        defaultFilePath: 'd:\\TempDb'
      }
    }
    serverConfigurationsManagementSettings: {
      sqlConnectivityUpdateSettings: {
        connectivityType: 'PUBLIC'
        port: 1433
        sqlAuthUpdatePassword: sqlAdminPassword
        sqlAuthUpdateUserName: sqlAdminUsername
      }
      additionalFeaturesServerConfigurations: {
        isRServicesEnabled: false
      }
    }
  }
}

resource sqlsvr1sqlDatabase 'Microsoft.Compute/virtualMachines/extensions@2020-12-01' = {
  name: 'sqlsvr1/CreateDatabase'
  location: region
  dependsOn: [
    sqlsvr1vm
  ]
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ConfigurationFunction: 'SqlServer.ps1\\SqlServer'
      ModulesUrl: 'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/DSC/SqlServer.zip'
      ConfigurationData: 'https://raw.githubusercontent.com/microsoft/OpenHack/main/byos/waf/source/dsc/DSC/ConfigurationData.psd1'
      Properties: [
        {
          Name: 'ServerCredential'
          Value: {
            Username: adminUsername
            Password: 'PrivateSettingsRef:ServerPassword'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
        {
          Name: 'DatabaseCredential'
          Value: {
            Username: 'webapp'
            Password: 'PrivateSettingsRef:DatabasePassword'
          }
          TypeName: 'System.Management.Automation.PSCredential'
        }
      ]
    }
    protectedSettings: {
      Items: {
        ServerPassword: adminPassword
        DatabasePassword: 'S0m3R@ndomW0rd$'
      }
    }
  }
}
