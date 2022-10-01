@description('Location for all resources.')
param location string = resourceGroup().location

@description('Tags object to apply to VMs')
param tags object

param sqlServerName string = 'Chr-${uniqueString(location)}'
param sqlServerDbName string = 'AdvWks'

@secure()
param sqlAdminPassword string

resource sqlServer 'Microsoft.Sql/servers@2021-11-01-preview' = {
  name: sqlServerName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    administratorLogin: 'local.admin'
    administratorLoginPassword: sqlAdminPassword
    minimalTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: 'Disabled'
    version: '12.0'
  }
}

resource sqlDb 'Microsoft.Sql/servers/databases@2021-11-01-preview' = {
  name: sqlServerDbName
  location: location
  tags: tags
  sku: {
    capacity: 5
    name: 'Free'
    tier: 'Free'
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
}

output sqlDB string = sqlServer.properties.fullyQualifiedDomainName
