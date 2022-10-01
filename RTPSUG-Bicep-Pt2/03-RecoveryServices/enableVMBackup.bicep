param vmName string
param vmRG string
param vaultName string = 'ChrimenyBackups'
var backupFabric = 'Azure'
var backupPolicyName = 'AzureDailyBackup'
var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${vmRG};${vmName}'
var protectedItem = 'vm;iaasvmcontainerv2;${vmRG};${vmName}'

resource recoveryServicesVault 'Microsoft.RecoveryServices/vaults@2022-04-01' existing = {
  name: vaultName
}

resource vm 'Microsoft.Compute/virtualMachines@2022-03-01' existing = {
  name: vmName
  scope: resourceGroup(vmRG)
}

resource vaultName_backupFabric_protectionContainer_protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-03-01' = {
  name: '${vaultName}/${backupFabric}/${protectionContainer}/${protectedItem}'
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: '${recoveryServicesVault.id}/backupPolicies/${backupPolicyName}'
    sourceResourceId: vm.id
  }
}
