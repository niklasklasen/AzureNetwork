targetScope = 'resourceGroup'

// Parameters Virtual WAN
param vWanName string
param vWanLocation string
param vWanAllowBranchToBranchTraffic bool
param vWanAllowVnetToVnetTraffic bool
param vWanDisableVpnEncryption bool

@description('Virtual WAN Type and Virtual HUB SKU')
@allowed([
  'Basic'
  'Standard'
])
param vWanType string

// Parameters Virtual Hubs
param vHubs array 

// Resources
resource vWan 'Microsoft.Network/virtualWans@2024-03-01' = {
  name: vWanName
  location:vWanLocation
  properties: {
    allowBranchToBranchTraffic: vWanAllowBranchToBranchTraffic
    allowVnetToVnetTraffic: vWanAllowVnetToVnetTraffic
    disableVpnEncryption: vWanDisableVpnEncryption
    type: vWanType
  }
}

resource virtualHub 'Microsoft.Network/virtualHubs@2024-03-01' = [ for vHub in vHubs: {
    name: vHub.vHubName
    location: vHub.location
    properties: {
      addressPrefix: vHub.vHubAddressPrefix
      allowBranchToBranchTraffic: vHub.vHubAllowBranchToBranchTraffic
      hubRoutingPreference: vHub.vHubRoutingPreference
      preferredRoutingGateway: vHub.vHubPreferredRoutingGateway
      sku: vWanType
      virtualWan:{
        id: vWan.id
      }
    }
  }
]

resource firewallPolicy 'Microsoft.Network/firewallPolicies@2024-03-01' = [ for (vHub, i) in vHubs: {
    name: vHub.firewallPolicyName
    location: vHub.location
    properties: {
      sku: {
        tier: vHub.firewallTier
      }
      dnsSettings: {
        enableProxy: vHub.firewallDnsProxyEnabled
        servers: vHub.firewallDnsServers
      }
    }
  }
]

resource firewall 'Microsoft.Network/azureFirewalls@2024-03-01' = [ for (vHub, i) in vHubs: {
    name: vHub.firewallName
    location:vHub.location
    zones: vHub.firewallZones
    properties:{
      hubIPAddresses: {
        publicIPs: {
          count: vHub.firewallPublicIpCount
        }
      }
      sku: {
        name: 'AZFW_Hub'
        tier: vHub.firewallTier
      }
      virtualHub: {
        id: virtualHub[i].id
      }
      firewallPolicy: {
        id: firewallPolicy[i].id
      }
    }
  }
]

resource vpnGateway 'Microsoft.Network/vpnGateways@2024-03-01' = [ for (vHub, i) in vHubs: if (vHub.deployVpnGateway) {
    name: vHub.vpnGatewayName
    location: vHub.location
    properties: {
      virtualHub: {
        id: virtualHub[i].id
      }
      vpnGatewayScaleUnit: vHub.vpnGatewayScaleUnit
    }
  }
]

resource expressRouteGateway 'Microsoft.Network/expressRouteGateways@2024-03-01' = [ for (vHub, i) in vHubs: if (vHub.deployExpressRouteGateway) {
    name: vHub.expressRouteGatewayName
    location: vHub.location
    properties: {
      virtualHub: {
        id: virtualHub[i].id
      }
    }
  }
]
