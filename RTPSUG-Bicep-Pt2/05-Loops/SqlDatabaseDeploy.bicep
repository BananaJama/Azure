@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags object to apply to VMs')
param tags object

param sqlServerName string
param sqlServerDbName string = 'AdvWks'

var deployStacks = [
  'qa'
  'dev'
  'prod'
]

resource sqlServer 'Microsoft.Sql/servers@2021-08-01-preview' existing = {
  name: sqlServerName
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-08-01-preview' = [for stack in deployStacks: {
  name: '${sqlServerDbName}-${stack}'
  location: location
  tags: tags
  sku: {
    capacity: 5
    name: 'Basic'
    tier: 'Basic'
  }
  parent: sqlServer
  identity: {
    type: 'None'
  }
  properties: {
    autoPauseDelay: 5
    catalogCollation: 'DATABASE_DEFAULT'
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    createMode: 'Default'
    isLedgerOn: false
    licenseType: 'LicenseIncluded'
    sampleName: 'AdventureWorksLT'
    zoneRedundant: false
  }
}]
