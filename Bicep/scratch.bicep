@description('Name of the virtual machine.')
param vmName string

@secure()
param adminPassword string

output name string = vmName
output pass string = adminPassword
