// Web Application Firewall Pattern
targetScope = 'subscription'
// Resources //
// Key Vault
// MAnaged Identity
// Route Table

// Diagnostic Option

// General Parameters
param environmentType string
param solutionName string
param regionShortName string
param lock object = {
  kind: 'CanNotDelete'
  name: 'DeleteLock-agw'
}

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
param pipAllocationMethod string = 'Dynamic'

// Web Application Firewall Policy Parameters
param wafManagedRuleSet object = {
  managedRuleSets: [
    {
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.2'
    }
  ]
}

// Application Gateway Parameters
param agwSku string = 'WAF_V2'
param agwCapacity int = 2
param agwFrontendPorts array = [
  {
    name: 'port443'
    properties: {
      port: 443
    }
  }
  {
    name: 'port80'
    properties: {
      port: 80
    }
  }
]
param agwEnableHttp2 bool = false

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

module modManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${miName}Deployment'
  params: {
    name: miName
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

module modWebApplicationFirewallPolicy 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.1.1' = {
  scope: resourceGroup(resResourceGroup.name)
  name: '${wafName}Deployment'
  params: {
    name: wafName
    location: resResourceGroup.location
    managedRules: wafManagedRuleSet
  }
}

module modApplicationGateway 'br/public:avm/res/network/application-gateway:0.5.1' = {
  name: '${agwName}Deployment'
  scope: resourceGroup(resResourceGroup.name)
  params: {
    name: agwName
    location: resResourceGroup.location
    managedIdentities: {
      userAssignedResourceIds: [
        modManagedIdentity.outputs.resourceId
      ]
    }
    sku: agwSku
    capacity: agwCapacity
    gatewayIPConfigurations: [
      {
        name: 'apw-ip-configuration'
        properties: {
          subnet: {
            id: modVirtualNetwork.outputs.subnetResourceIds
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'public'
        properties: {
          publicIPAddress: {
            id: modPublicIPAddress.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: agwFrontendPorts 
    enableHttp2: agwEnableHttp2
    firewallPolicyResourceId: modWebApplicationFirewallPolicy.outputs.resourceId
    lock: lock
  
  }
}
