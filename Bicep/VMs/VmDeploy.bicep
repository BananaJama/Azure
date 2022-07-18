@description('Name of the virtual machine.')
param vmName string

@description('Size of the virtual machine.')
@allowed([
  'Standard_B2ms'
  'Standard_DS3_v2'
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

@description('Tags object to apply to VMs')
param tags object

@description('Local admin password')
@secure()
param adminPassword string

@description('Username for the Virtual Machine.')
param adminUsername string

var subnetName = 'SVNet-Core'
var nicName = '${vmName}-PrimaryNIC'
var backupPolicyName = 'AzureDailyBackup'
var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vmName}'
var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup().name};${vmName}'

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: 'backups'
}

resource vnet 'Microsoft.Network/virtualNetworks@2021-05-01' existing = {
  name: 'VNet-ChrimenyCore'
  scope: resourceGroup('SharedResources')
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' existing = {
  name: '${vnet.name}/${subnetName}'
  scope: resourceGroup('SharedResources')
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

resource vaultName_backupFabric_protectionContainer_protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-03-01' = {
  name: '${recoveryVault.name}/Azure/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${recoveryVault.id}/backupPolicies/${backupPolicyName}'
    sourceResourceId: vm.id
  }
}
