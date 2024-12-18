targetScope = 'subscription'

// Parameters
param parLocation string
param parResourceGroupName string
param parKeyVaultName string
param parManagedIdentityName string
param parRouteTableName string
param parVnetName string
param parVnetAddressPrefix array
param parPublicIpAddressName string
param parWebApplicationFirewallPolicyName string
param parWebApplicationFirewallManagedRuleSets array = [
  {
    ruleSetType: 'OWASP'
    ruleSetVersion: '3.2'
  }
]
param parApplicationGatewayName string
param parApplicationGayewayBackendPools array = [
  {
    name: 'tempBackendAddressPool'
  }
]
param parApplicationGatewayBackendHttpSettingsCollection array = [
  {
    name: 'tempBackendHttpSettings'
    properties: {
      cookieBasedAffinity: 'Disabled'
      port: 80
      protocol: 'Http'
    }
  }
]
param parApplicationGatewayFrontendPorts array = [
  {
    name: 'frontendPort'
    properties: {
      port: 80
    }
  }
]
param parApplicationGatewayHttpListeners array = [
  {
    name: 'tempHttpListener'
    properties: {
      frontendIPConfiguration: {
        id: '${subscription().id}/resourceGroups/${parResourceGroupName}/providers/Microsoft.Network/applicationGateways/${parApplicationGatewayName}/frontendIPConfigurations/frontendIPConfig'
      }
      frontendPort: {
        id: '${subscription().id}/resourceGroups/${parResourceGroupName}/providers/Microsoft.Network/applicationGateways/${parApplicationGatewayName}/frontendPorts/frontendPort'
      }
      hostName: 'temp.demo'
      protocol: 'Http'
    }
  }
]

param parApplicationGatewayRequestRoutingrules array = [
  {
    name: 'tempRequestRoutingRule'
    properties: {
      backendAddressPool: {
        id: '${subscription().id}/resourceGroups/${parResourceGroupName}/providers/Microsoft.Network/applicationGateways/${parApplicationGatewayName}/backendAddressPools/tempBackendAddressPool'
      }
      backendHttpSettings: {
        id: '${subscription().id}/resourceGroups/${parResourceGroupName}/providers/Microsoft.Network/applicationGateways/${parApplicationGatewayName}/backendHttpSettingsCollection/tempBackendHttpSettings'
      }
      httpListener: {
        id: '${subscription().id}/resourceGroups/${parResourceGroupName}/providers/Microsoft.Network/applicationGateways/${parApplicationGatewayName}/httpListeners/tempHttpListener'
      }
      priority: 100
      ruleType: 'Basic'
    }
  }
]

// Resources
module modResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'resourceGroupDeployment'
  params: {
    name: parResourceGroupName
    location: parLocation
  }
}

module modKeyVault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  name: 'keyVaultDeployment'
  params: {
    name: parKeyVaultName
  }
}

module modManagedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  name: 'managedIdentityDeployment'
  params: {
    name: parManagedIdentityName
  }
}

module modRoleAssignment 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modManagedIdentity
  ]
  name: 'roleAssignmentDeployment'
  params: {
    principalId: modManagedIdentity.outputs.principalId
    resourceId: modKeyVault.outputs.resourceId
    roleDefinitionId: 'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba'
  }
}

module modNetworkSecurityGroup 'br/public:avm/res/network/network-security-group:0.5.0' = {
  name: 'networkSecurityGroupDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: 'waf-snet-nsg'
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
        name: 'AllowAzureLoadBalancer'
        properties: {
          access: 'Allow'
          description: 'Allow traffic from AzureLoadBalancer.'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
          direction: 'Inbound'
          priority: 3910
          protocol: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
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
  }
}

module modRouteTable 'br/public:avm/res/network/route-table:0.4.0' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  name: 'routeTableDeployment'
  params: {
    name: parRouteTableName
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
        name: 'waf-snet'
        addressPrefixes: parVnetAddressPrefix
        networkSecurityGroupResourceId: modNetworkSecurityGroup.outputs.resourceId
        routeTableResourceId: modRouteTable.outputs.resourceId
      }
    ]
    
  }
}

module modPublicIpAddress 'br/public:avm/res/network/public-ip-address:0.7.0' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  name: 'publicIpAddressDeployment'
  params: {
    name: parPublicIpAddressName
  }
}

module modWebApplicationFirewallPolicy 'br/public:avm/res/network/application-gateway-web-application-firewall-policy:0.1.1' = {
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  name: 'webApplicationFirewallPolicyDeployment'
  params: {
    name: parWebApplicationFirewallPolicyName
    managedRules: {
      managedRuleSets: parWebApplicationFirewallManagedRuleSets
    }
  }
}

module modApplicationGateway 'br/public:avm/res/network/application-gateway:0.5.1' = {
  name: 'applicationGatewayDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parApplicationGatewayName
    managedIdentities: {
      userAssignedResourceIds: [
        modManagedIdentity.outputs.resourceId
      ]
    }
    backendAddressPools: parApplicationGayewayBackendPools
    backendHttpSettingsCollection: parApplicationGatewayBackendHttpSettingsCollection
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig'
        properties: {
          publicIPAddress: {
            id: modPublicIpAddress.outputs.resourceId
          }
        }
      }
    ]
    frontendPorts: parApplicationGatewayFrontendPorts
    gatewayIPConfigurations: [
      {
        name: 'publicIPConfig'
        properties: {
          subnet: {
            id: modVirtualNetwork.outputs.subnetResourceIds[0]
          }
        }
      }
    ]
    httpListeners: parApplicationGatewayHttpListeners
    requestRoutingRules: parApplicationGatewayRequestRoutingrules
    sku: 'WAF_v2'
    firewallPolicyResourceId: modWebApplicationFirewallPolicy.outputs.resourceId
  }
}
