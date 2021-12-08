param region string
param vnetName string
param elbName string
param storageWeb string
param storageProc string
param storageSql string
param web1vmDnsLabel string
param web2vmDnsLabel string
param worker1vmDnsLabel string
param sqlsvr1vmDnsLabel string
param elbDnsLabel string
param adminUsername string
@secure()
param adminPassword string
param sqlAdminUsername string
@secure()
param sqlAdminPassword string

module storage './storage.bicep' = {
  name: 'storage'
  params: {
    region: region
    storageWeb: storageWeb
    storageProc: storageProc
    storageSql: storageSql
  }
}

module network './network.bicep' = {
  name: 'network'
  params: {
    region: region
    vnetName: vnetName
    elbName: elbName
    web1vmDnslabel: web1vmDnsLabel
    web2vmDnslabel: web2vmDnsLabel
    worker1vmDnslabel: worker1vmDnsLabel
    sqlsvr1vmDnslabel: sqlsvr1vmDnsLabel
    elbDnsLabel: elbDnsLabel
  }
}

module vms './vms.bicep' = {
  name: 'vms'
  params: {
    region: region
    web1vmNicId: network.outputs.web1vmNicId
    web2vmNicId: network.outputs.web2vmNicId
    worker1vmNicId: network.outputs.worker1vmNicId
    sqlsvr1vmNicId: network.outputs.sqlsvr1vmNicId
    adminUsername: adminUsername
    adminPassword: adminPassword
    sqlAdminUsername: sqlAdminUsername
    sqlAdminPassword: sqlAdminPassword
  }
}
