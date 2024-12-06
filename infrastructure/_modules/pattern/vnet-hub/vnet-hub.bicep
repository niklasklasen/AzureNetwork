targetScope = 'resourceGroup'

// Parameters
param parVnetName string
param parGatewaySubnetNSGName string
param parAzureFirewallSubnetNSGName string
param parAzureFirewallManagementSubnetNSGName string
param parGatewaySubnetRTName string 
param parAzureFirewallSubnetRTName string
param parAzureFirewallManagementSubnetRTName string
param parAzureFirewallName string
param parAzureFirewallPolicyName string
@allowed(
  [
    'Basic'
    'Standard'
    'Premium'
  ]
)
param parAzureFirewallSku string = 'Standard'
param parAzureFirewallPIPName string

// Resources

resource resGatewaySubnetNSG 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: parGatewaySubnetNSGName
  location: resourceGroup().location
}

resource resAzureFirewallSubnetNSG 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: parAzureFirewallSubnetNSGName
  location: resourceGroup().location
}

resource resAzureFirewallManagementSubnetNSG 'Microsoft.Network/networkSecurityGroups@2024-03-01' = {
  name: parAzureFirewallManagementSubnetNSGName
  location: resourceGroup().location
}

resource resGatewaySubnetRT 'Microsoft.Network/routeTables@2024-03-01' = {
  name: parGatewaySubnetRTName
  location: resourceGroup().location
}

resource resAzureFirewallSubnetRT 'Microsoft.Network/routeTables@2024-03-01' = {
  name: parAzureFirewallSubnetRTName
  location: resourceGroup().location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: 'AllToInternet'
        properties: {
          nextHopType: 'Internet'
          addressPrefix: '0.0.0.0/0'
        }
      }
    ]
  }
}

resource resAzureFirewallManagementSubnetRT 'Microsoft.Network/routeTables@2024-03-01' = {
  name: parAzureFirewallManagementSubnetRTName
  location: resourceGroup().location
}

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
    routeTable: {
      id: resGatewaySubnetRT.id
    }
    networkSecurityGroup: {
      id: resGatewaySubnetNSG.id
    }
  }
}

resource resAzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'AzureFirewallSubnet'
  parent: resVirtualNetwork
  properties: {
    addressPrefix: '10.0.1.0/26'
    routeTable: {
      id: resAzureFirewallSubnetRT.id
    }
    networkSecurityGroup: {
      id: resAzureFirewallSubnetNSG.id
    }
  }
}

resource resAzureFirewallManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-03-01' = {
  name: 'AzureFirewallManagementSubnet'
  parent: resVirtualNetwork
  properties: {
    addressPrefix: '10.0.2.0/26'
    routeTable: {
      id: resAzureFirewallManagementSubnetRT.id
    }
    networkSecurityGroup: {
      id: resAzureFirewallManagementSubnetNSG.id
    }
  }
}

resource resPublicIPAddress 'Microsoft.Network/publicIPAddresses@2024-03-01' = {
  name: parAzureFirewallPIPName
  location: resourceGroup().location
  
}

resource resAzureFirewallPolicy 'Microsoft.Network/firewallPolicies/firewallPolicyDrafts@2024-03-01' = {
  name: parAzureFirewallPolicyName
  location: resourceGroup().location
  properties: {
    dnsSettings: {
      enableProxy: true
    }
    }
  }
}

resource resAzureFirewall 'Microsoft.Network/azureFirewalls@2024-03-01' = {
  name: parAzureFirewallName
  location: resourceGroup().location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    firewallPolicy: {
      id: resAzureFirewallPolicy.id
    }
    sku: {
      name: 'AZFW_VNet'
      tier: parAzureFirewallSku
    }
    ipConfigurations: [
      {
        name: 'AzureFirewallIPConfiguration'
        properties:{
          subnet: {
            id: resAzureFirewallSubnet
          }
          publicIPAddress: {
            id: 
          }
        }
      }
    ]
  }
}

output outAzureFirewall string = resAzureFirewall.id
