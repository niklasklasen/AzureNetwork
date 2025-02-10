using 'main.bicep'

param parResourceGroupName = 'p-dnsResolver-rg'
param parLocation = 'swedencentral'
param parNetworkSecurityGroupName = 'p-dnsResolver-nsg'
param parVnetName = 'p-dnsResolver-vnet'
param parVnetAddressPrefix = ['10.0.1.0/26']
param parInboundSubnetAddressPrefix = ['10.0.1.0/27']
param parOutboundSubnetAddressPrefix = ['10.0.1.32/27']
param parDnsResolverName = 'p-dnsResolver-dnspr'
param parDnsForwardingRulsetName = 'p-dnsResolver-dnsfr'
param parDnsForwardingRules = [
  {
    name: 'rule1'
    domainName: 'contoso.'
    targetDnsServers: [
      {
        ipAddress: '10.100.0.10'
        port: 53
      }
      {
        ipAddress: '10.100.0.11'
        port: 53
      }
    ]
  }
  {
    name: 'rule2'
    domainName: 'fabrikam.'
    targetDnsServers: [
      {
        ipAddress: '10.110.0.10'
        port: 53
      }
    ]
  }
]
