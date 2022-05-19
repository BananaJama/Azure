@description('Name of the virtual machine.')
param vmName string

@description('Size of the virtual machine.')
@allowed([
  'Standard_B2ms'
])
param vmSize string = 'Standard_B2ms'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-Datacenter'
  '2019-Datacenter'
  '2019-Datacenter-Core'
])
param OSVersion string = '2019-Datacenter'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Subnets to deploy a VM into')
@allowed([
  'SBNT-General'
])
param subnetName string

@description('Domain to join VM to')
@allowed([
  'CHRIMENY'
])
param domain string

@description('Tags object to apply to VMs')
param tags object

@description('Username for the Virtual Machine.')
param adminUsername string

@description('Local admin password')
@secure()
param adminPassword string

var domainJoinUser = 'administrator'

var nicName = '${vmName}-PrimaryNIC'

  resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
    name: 'VNET-Chrimeny'
    scope: resourceGroup()
  }
  
  resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
    name: '${vnet.name}/${subnetName}'
    scope: resourceGroup()
  }

resource nic 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicName
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}

resource vm 'Microsoft.Compute/virtualMachines@2021-11-01' = {
  name: vmName
  location: location
  tags: tags
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'StandardSSD_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

resource vmeDomJoin 'Microsoft.Compute/virtualMachines/extensions@2021-03-01' = if (domain == 'CHRIMENY') {
  parent: vm
  name: 'domainJoinSugar'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: '${domain}.corp'
      user: '${domain}\\${domainJoinUser}'
      restart: true
      options: 3
    }
    protectedSettings: {
      password: adminPassword
    }
  }
}
