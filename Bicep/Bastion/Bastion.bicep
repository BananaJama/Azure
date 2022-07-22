// Creates an Azure Bastion Subnet and host in the specified virtual network
@description('The Azure region where the Bastion should be deployed')
param location string = resourceGroup().location

@description('Virtual network name')
param vNetName string = 'VNET-ChrimenyPublic'

@description('The address prefix to use for the Bastion subnet')
param addressPrefix string = '172.18.0.0/24'

@description('The name of the Bastion public IP address')
param publicIpName string = 'PIP-Bastion'

@description('The name of the Bastion host')
param bastionHostName string = 'Bastion-Jumpbox'

// The Bastion Subnet is required to be named 'AzureBastionSubnet'
var subnetName = 'AzureBastionSubnet'

resource vNet 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: vNetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '172.18.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'SBNT-General'
        properties: {
          addressPrefix: '172.18.1.0/24'
        }
      }
    ]
  }
}

resource bastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-06-01' = {
  name: subnetName
  parent: vNet
  properties: {
    addressPrefix: addressPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Disabled'
  }
}

resource publicIpAddressForBastion 'Microsoft.Network/publicIpAddresses@2020-08-01' = {
  name: publicIpName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource bastionHost 'Microsoft.Network/bastionHosts@2020-06-01' = {
  name: bastionHostName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          subnet: {
            id: bastionSubnet.id
          }
          publicIPAddress: {
            id: publicIpAddressForBastion.id
          }
        }
      }
    ]
  }
}
