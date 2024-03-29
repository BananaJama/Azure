@minLength(3)
@maxLength(11)
param storagePrefix string = 'occ'

@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param storageSKU string = 'Standard_LRS'

param location string = resourceGroup().location

var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: uniqueStorageName
  location: location
  sku: {
    name: storageSKU
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
  }
}

output storageName string = stg.name
output storageEndpoint object = stg.properties.primaryEndpoints

// New-AzResourceGroupDeployment -Name 'OCC-STG' -ResourceGroupName 'OCC-Demos' -TemplateFile ./Example2.json
// az deployment group create --resource-group OCC-Demos --template-file ./Example2.bicep
