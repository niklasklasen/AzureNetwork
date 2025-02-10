targetScope = 'subscription'

// Parameters
param parResourceGroupName string
param parLocation string
param parNetworkSecurityGroupName string
param parVnetName string
param parVnetAddressPrefix array
param parInboundSubnetAddressPrefix array
param parOutboundSubnetAddressPrefix array
param parDnsResolverName string
param parDnsForwardingRulsetName string
param parDnsForwardingRules array


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
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parNetworkSecurityGroupName
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
      {
        name: 'allowInetnerAccess'
        properties: {
          access: 'Allow'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '80'
            '443'
          ]
          direction: 'Inbound'
          priority: 110
          protocol: 'Tcp'
          sourceAddressPrefix: 'Internet'
          sourcePortRange: '*'
        }
      }
      {
        name: 'AllowDNS'
        properties: {
          access: 'Allow'
          description: 'Allow DNS traffic'
          destinationAddressPrefix: '*'
          destinationPortRange: '53'
          direction: 'Inbound'
          priority: 210
          protocol: '*'
          sourceAddressPrefix: '*'
          sourcePortRange: '53'
        }
      }
    ]
  }
}

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'virtualNetworkDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parVnetName
    addressPrefixes: parVnetAddressPrefix
    subnets: [
      {
        name: 'DnsInboundSubnet'
        addressPrefixes: parInboundSubnetAddressPrefix
        networkSecurityGroupResourceId: modNetworkSecurityGroup.outputs.resourceId
        delegation: 'Microsoft.Network/dnsResolvers'
      }
      {
        name: 'DnsOutboundSubnet'
        addressPrefixes: parOutboundSubnetAddressPrefix
        networkSecurityGroupResourceId: modNetworkSecurityGroup.outputs.resourceId
        delegation: 'Microsoft.Network/dnsResolvers'
      }
    ]
  }
}

module modDnsResolver 'br/public:avm/res/network/dns-resolver:0.5.1' = {
  name: 'dnsResolverDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parDnsResolverName
    virtualNetworkResourceId: modVirtualNetwork.outputs.resourceId
    inboundEndpoints: [
      {
        name: '${parDnsResolverName}-inbound'
        subnetResourceId: modVirtualNetwork.outputs.subnetResourceIds[0]
      }
    ]
    location: parLocation
    outboundEndpoints: [
      {
        name: '${parDnsResolverName}-outbound'
        subnetResourceId: modVirtualNetwork.outputs.subnetResourceIds[1]
      }
    ]
  }
}

module modDnsForwardingRuleset 'br/public:avm/res/network/dns-forwarding-ruleset:0.5.1' = {
  name: 'dnsForwardingRulesetDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    dnsForwardingRulesetOutboundEndpointResourceIds: [
      '${modDnsResolver.outputs.resourceId}/outboundEndpoints/${parDnsResolverName}-outbound'
    ]
    name: parDnsForwardingRulsetName
    location: parLocation
    virtualNetworkLinks: [
      {
        name: 'dnspr-vnet-link'
        virtualNetworkResourceId: modVirtualNetwork.outputs.resourceId
      }
    ]
    forwardingRules: [ for rule in parDnsForwardingRules: {
        domainName: rule.domainName
        forwardingRuleState: 'Enabled'
        name: rule.name
        targetDnsServers: rule.targetDnsServers
      }
    ]
  }
}
