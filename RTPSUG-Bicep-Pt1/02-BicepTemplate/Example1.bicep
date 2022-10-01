targetScope = 'subscription'

param location string = 'eastus2'

var resGrpName = 'RTPSUG-Demos'

resource myResGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resGrpName
}

output myVarOutput string = resGrpName
output myParamOutput string = location
output resGrpLocation string = myResGrp.location

/*
After we build this resource group we will put resources in it.
This is a block of comments.
Don't forget to build this bicep file into an ARM Template.
*/

// New-AzDeployment -TemplateFile Example1.json -Location 'EastUS2'
