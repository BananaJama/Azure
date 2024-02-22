targetScope = 'subscription'

param location string = 'eastus2'

var resGrpName = 'OCC-Demos'

resource myResGrp 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resGrpName
}

output myVarOutput string = resGrpName
output myParamOutput string = location
output resGrpLocation string = myResGrp.location

/*
This is how you provide a block of comments.
After we build this resource group we will put resources in it.
Don't forget to build this bicep file into an ARM Template.
*/


// This is how you provide single line comments.
// New-AzDeployment -TemplateFile Example1.json -Location 'EastUS2'
// az deployment sub create --location eastus2 --template-file ./Example1.bicep
