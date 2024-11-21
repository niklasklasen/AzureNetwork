targetScope = 'resourceGroup'

// Parameters
param parVnetName string

// Resources
resource resVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: parVnetName
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/22'
      ]
    }
  }
}

resource resGatewaySubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'GatewaySubnet'
  parent: resVirtualNetwork
  properties: {
    addressPrefix: '10.0.0.0/26'
  }
}

resource resAzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'AzureFirewallSubnet'
  parent: resVirtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/26'
  }
}

resource resAzureFirewallManagmentSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'AzureFirewallManagmentSubnet'
  parent: resVirtualNetwork
  properties: {
    addressPrefix: '10.0.2.0/26'
  }
}
