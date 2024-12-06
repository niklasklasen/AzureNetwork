// Web Application Firewall Pattern
targetScope = 'subscription'
// Diagnostic Option

// General Parameters
param environmentType string
param solutionName string
param regionShortName string
param lock object = {
  kind: 'CanNotDelete'
  name: 'DeleteLock-agw'
}

param subscriptionId string = '178eb97e-2a58-4e6a-81a3-3ad481221fe0'

// Resource Group Parameters 
param rgLocation string

// Virtual Network Parameters
param vnetAddressPrefixes array
param vnetDnsServers array = []
param vnetDDoSProtectionId string = ''
param snetAddressPrefix string


// Public IP Address Parameters
@allowed([
  'Static'
  'Dynamic'
])
param pipAllocationMethod string = 'Static'

param parWebApplicationFirewallRules object

 // Key Vault Parameters
param kvEnablePurgeProtection bool = false
param kvEnableRbacAuthorization bool = true

// Variables
var rgName = '${environmentType}-${solutionName}-${regionShortName}-rg'
var agwName = '${environmentType}-${solutionName}-${regionShortName}-agw'
var vnetName = '${environmentType}-${solutionName}-${regionShortName}-vnet'
var nsgName = '${environmentType}-${solutionName}-${regionShortName}-snet-nsg'
var pipName = '${environmentType}-${solutionName}-${regionShortName}-pip'
var wafName = '${environmentType}-${solutionName}-${regionShortName}-waf'
var miName = '${environmentType}-${solutionName}-${regionShortName}-mi'
var kvName = '${environmentType}-${solutionName}-${regionShortName}-kv'
var rtName = '${environmentType}-${solutionName}-${regionShortName}-rt'

// Resources
resource resResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: rgName
  location: rgLocation
}

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${nsgName}Deployment'
  params: {
    name: nsgName
    location: resResourceGroup.location
    securityRules: [
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
        name: 'allowGatewayManager'
        properties: {
          access: 'Allow'
          description: 'Allow traffic from GatewayManager. This port range is required for Azure infrastructure communication.'
          destinationAddressPrefix: '*'
          destinationPortRanges: [
            '65200-65535'
          ]
          direction: 'Inbound'
          priority: 3900
          protocol: '*'
          sourceAddressPrefix: 'GatewayManager'
          sourcePortRange: '*'
        }
      }
    ]
    lock: lock
  }
}

module modRouteTable 'br/public:avm/res/network/route-table:0.4.0' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${rtName}Deployment'
  params: {
    name: rtName
    location: resResourceGroup.location
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'Internet'
          hasBgpOverride: false
        }
      }
    ]
    lock: lock
  }
}

module modKeyVault 'br/public:avm/res/key-vault/vault:0.10.2' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${kvName}Deployment'
  params: {
    name: kvName
    lock: lock
    location: resResourceGroup.location
    enablePurgeProtection: kvEnablePurgeProtection
    enableRbacAuthorization: kvEnableRbacAuthorization
  }
}

module modVirtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${vnetName}Deployment'
  params: {
    name: vnetName
    location: resResourceGroup.location
    addressPrefixes: vnetAddressPrefixes
    dnsServers: vnetDnsServers
    ddosProtectionPlanResourceId:vnetDDoSProtectionId
    subnets: [
      {
        name: 'waf-snet'
        addressPrefix: snetAddressPrefix
        networkSecurityGroupResourceId: modNetworkSecurityGroup.outputs.resourceId
        routeTableResourceId: modRouteTable.outputs.resourceId
      }
    ]
    lock: lock
  }
}

module modPublicIPAddress 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  name: '${pipName}Deployment'
  scope: resourceGroup(resResourceGroup.name)
  params: {
    name: pipName
    location: resResourceGroup.location
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: pipAllocationMethod
    lock: lock
  }
}

module modWebApplicationFirewall '../../_modules/pattern/waf-spoke/waf.bicep' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${wafName}Deployment'
  params: {
    parLocation: resResourceGroup.location
    parManagedIdentityName: miName
    parPublicIpId: modPublicIPAddress.outputs.resourceId
    parResourceGroupName: rgName
    parSubscriptionId: subscriptionId
    parVirtualNetworkSubnetId: modVirtualNetwork.outputs.subnetResourceIds[0]
    parWebApplicationFirewallName: agwName
    parWebApplicationFirewallPolicyName: wafName
    parWebApplicationFirewallRules: parWebApplicationFirewallRules
  }
}
