param location string = resourceGroup().location

resource recoveryVault 'Microsoft.RecoveryServices/vaults@2022-04-01' = {
  name: 'ChrimenyBackups'
  location: location
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
  properties: {}
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-03-01' = {
  name: 'AzureDailyBackup'
  location: location
  parent: recoveryVault
  properties: {
        backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays: 5
    timeZone: 'Eastern Standard Time'
    protectedItemsCount: 0
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Weekly'
      scheduleRunDays: [
        'Monday'
        'Tuesday'
        'Wednesday'
        'Thursday'
        'Friday'
      ]
      scheduleRunTimes: [
        '2021-07-13T01:00:00Z'
      ]
      scheduleWeeklyFrequency: 0
    }
    retentionPolicy: {
      retentionPolicyType: 'LongTermRetentionPolicy'
      weeklySchedule: {
        daysOfTheWeek: [
          'Monday'
          'Tuesday'
          'Wednesday'
          'Thursday'
          'Friday'
        ]
        retentionTimes: [
          '2021-07-13T01:00:00Z'
        ]
        retentionDuration: {
          count: 3
          durationType: 'Weeks'
        }
      }
    }
  }
}

output VaultID string = recoveryVault.id
