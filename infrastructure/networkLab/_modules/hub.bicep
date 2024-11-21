targetScope = 'resourceGroup'

// Parameters
param parVnetName string
param parGatewaySubnetNSGName string
param parAzureFirewallSubnetNSGName string
param parAzureFirewallManagementSubnetNSGName string
param parGatewaySubnetRTName string 
param parAzureFirewallSubnetRTName string
param parAzureFirewallManagementSubnetRTName string
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
