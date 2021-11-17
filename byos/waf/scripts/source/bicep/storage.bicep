param region string
param storageWeb string
param storageProc string
param storageSql string

resource webStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageWeb
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    
  }
}

resource procStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageProc
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    
  }
}

resource sqlStorage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageSql
  location: region
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    
  }
}

output webStorageId string = webStorage.id
output procStorageId string = procStorage.id
output sqlStorageId string = sqlStorage.id
