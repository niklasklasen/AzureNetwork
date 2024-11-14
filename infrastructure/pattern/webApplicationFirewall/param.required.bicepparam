using 'main.bicep'

// General Parameters
param environmentType = 't'
param solutionName = 'waf'
param regionShortName = 'sec'
// Resource Group Parameters 
param rgLocation = 'swedencentral'
// Virtual Network Parameters
param vnetAddressPrefixes = [
  '10.0.1.0/24'
]
param snetAddressPrefix = '10.0.1.0/25'


