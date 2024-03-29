@minLength(3)
@maxLength(11)
param storagePrefix string

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
param storageSKU string

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
output storageLocation string = stg.location
output storageEndpoint object = stg.properties.primaryEndpoints

// New-AzResourceGroupDeployment -Name 'OOC-STG2' -ResourceGroupName 'OCC-Demos' -TemplateFile ./Example1.bicep
// az deployment group create --name BicepParams1 --resource-group 'OCC-Demos' --template-file ./Example1.bicep --parameters ./Example1.bicepparam
// az deployment group create --name BicepParams2 --resource-group 'OCC-Demos' --template-file ./Example1.bicep --parameters ./Example1.param.json
