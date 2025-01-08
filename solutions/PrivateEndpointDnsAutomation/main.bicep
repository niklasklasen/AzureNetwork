targetScope = 'subscription'

// Parameters
param parLocation string
param parResourceGroupName string
param parVnetName string
param parVnetAddressPrefix array

// Resources
module modResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'resourceGroupDeployment'
  params: {
    name: parResourceGroupName
    location: parLocation
  }
}

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'networkSecurityGroupDeployment'
  scope: resourceGroup(modResourceGroup.name)
  params: {
    name: 'p-appService-snet-nsg'
    securityRules: [
      {
        name: 'default-deny-all'
        properties: {
          access: 'Deny'
          direction: 'Inbound'
          priority: 4000
          protocol: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
        }
      }
    ]
  }
}

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'virtualNetworkDeployment'
  scope: resourceGroup(modResourceGroup.name)
  params: {
    name: parVnetName
    addressPrefixes: parVnetAddressPrefix
    subnets: [
      {
        name: 'p-appService-snet'
        addressPrefixes: parVnetAddressPrefix
        networkSecurityGroupResourceId: modNetworkSecurityGroup.outputs.resourceId
      }
    ]
    
  }
}

module modFunctionApp 'br/public:avm/res/web/site:0.12.0' = {
  name: 
  scope: resourceGroup(modResourceGroup.name)
}
