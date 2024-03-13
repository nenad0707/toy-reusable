@description('The name of the App Service app. This name must be globally unique.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'stor${uniqueString(resourceGroup().id)}'

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the SKU to use for the Azure Storage account.')
param storageAccountSkuName string = 'Standard_LRS'
param vmName string

var softDeleteRetentionPeriodDays = 7

// This resource block defines the storage account resource
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: storageAccountSkuName
  }
  properties: {
    supportsHttpsTrafficOnly: true
    allowSharedKeyAccess: false
  }

  resource blobService 'blobServices' = {
    name: 'default'
    properties: {
      deleteRetentionPolicy: {
        enabled: true
        days: softDeleteRetentionPeriodDays
      }
      containerDeleteRetentionPolicy: {
        enabled: true
        days: softDeleteRetentionPeriodDays
      }
    }
  }
}

// This resource block defines the virtual machine resource
resource vm 'Microsoft.Compute/virtualMachines@2022-08-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
  }
}

// This variable stores the name of the storage account
output storageAccountName string = storageAccount.name
*/
// Terminate the multi-line comment
