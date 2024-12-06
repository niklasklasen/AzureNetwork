targetScope = 'resourceGroup'

// Parameters
param location string
param vnetName string
param vnetAddressPrefix string
param vnetDnsServers array
param subnets array = [
  {
    name: 'ampls-snet'
    addressPrefix: vnetAddressPrefix
  }
]

param privateLinkScopeName string
param privateLinkScopeIngestionAccessMode string
param privateLinkScopeQueryAccessMode string

// Resources

module vnet '../../resource/vnet/vnet.bicep' = {
  name: '${vnetName}-Deployment'
  params: {
    location: location
    subnets: subnets
    vnetAddressPrefix: vnetAddressPrefix
    vnetDnsServers: vnetDnsServers
    vnetName: vnetName
  }
}

resource privateLinkScope 'microsoft.insights/privateLinkScopes@2021-07-01-preview' = {
  name: privateLinkScopeName
  location: 'global'
  properties: {
    accessModeSettings: {
      ingestionAccessMode: privateLinkScopeIngestionAccessMode
      queryAccessMode: privateLinkScopeQueryAccessMode
    }
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2024-03-01' = {
  name: '${privateLinkScopeName}-pe'
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: '${privateLinkScopeName}-pe'
        properties: {
          groupIds: [
            'azuremonitor'
          ]
          privateLinkServiceId: privateLinkScope.id
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-Approved'
            actionsRequired: 'None'
          }
        }
      }
    ]
    customNetworkInterfaceName: '${privateLinkScopeName}-pe-nic'
    subnet: {
      id: vnet.outputs.subnets[0].id
    }
  }
}
