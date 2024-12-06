// Parameters
@description('Specifies the name of the Web Application Firewall')
param parWebApplicationFirewallName string

@description('Specifies the name of the Web Application Firewall')
param parWebApplicationFirewallPolicyName string

@description('Specifies the location of the Web Application Firewall')
param parLocation string

@description('Specifies the id of the Public IP')
param parPublicIpId string

@description('Specifies the id of the Virtual network Subnet')
param parVirtualNetworkSubnetId string

@description('Specifies the publishing rules for the Web Application Firewall')
param parWebApplicationFirewallRules object

@description('Name of the Managed Identity that is linked to th WAF')
param parManagedIdentityName string

@description('ID of rhe subscription that the Managed Identity is to be deployed in')
param parSubscriptionId string

@description('Name of the Resource Group that the Managed Identity is to be deployed in')
param parResourceGroupName string

// Resources
resource resManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: parManagedIdentityName
  location: parLocation
}


resource resWebApplicationFirewallPolicy 'Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies@2021-08-01' = {
  name: parWebApplicationFirewallPolicyName
  location: parLocation
  properties: {
    policySettings: {
      requestBodyCheck: true
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
      state: 'Enabled'
      mode: 'Prevention'
    }
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'OWASP'
          ruleSetVersion: '3.1'
        }
      ]
    }
  }
}

resource resWebApplicationFirewall 'Microsoft.Network/applicationGateways@2021-08-01' = {
  name: parWebApplicationFirewallName
  location: parLocation
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '/subscriptions/${parSubscriptionId}/resourceGroups/${parResourceGroupName}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/${parManagedIdentityName}': {}
    }
  }
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        properties: {
          subnet: {
            id: parVirtualNetworkSubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: parPublicIpId
          }
        }
      }
    ]
    frontendPorts: [for frontendPort in parWebApplicationFirewallRules.frontendPorts: {
      name: frontendPort.name
      properties: {
        port: frontendPort.port
      }
    }]
    backendAddressPools: [for backendAddressPools in parWebApplicationFirewallRules.backendAddressPools: {
      name: backendAddressPools.name
      properties: {
        backendAddresses: backendAddressPools.backendAddresses
      }
    }]
    backendHttpSettingsCollection: [for backendHttpSettingsCollection in parWebApplicationFirewallRules.backendHttpSettingsCollection: {
      name: backendHttpSettingsCollection.name
      properties: {
        port: backendHttpSettingsCollection.port
        protocol: backendHttpSettingsCollection.protocol
        cookieBasedAffinity: backendHttpSettingsCollection.cookieBasedAffinity
        pickHostNameFromBackendAddress: false
        requestTimeout: 20
      }
    }]
    httpListeners: [for httpListener in parWebApplicationFirewallRules.httpListeners: {
      name: httpListener.name
      properties: {
        firewallPolicy: {
          id: resWebApplicationFirewallPolicy.id
        }
        frontendIPConfiguration: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', parWebApplicationFirewallName, 'appGwPublicFrontendIp')
        }
        frontendPort: {
          id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', parWebApplicationFirewallName, httpListener.frontendPort)
        }
        protocol: httpListener.protocol
        requireServerNameIndication: httpListener.requireServerNameIndication
      }
    }]
    requestRoutingRules: [for requestRoutingRule in parWebApplicationFirewallRules.requestRoutingRules: {
      name: requestRoutingRule.name
      properties: {
        ruleType: 'Basic'
        priority: 10
        httpListener: {
          id: resourceId('Microsoft.Network/applicationGateways/httpListeners', parWebApplicationFirewallName, requestRoutingRule.httpListener)
        }
        backendAddressPool: {
          id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', parWebApplicationFirewallName, requestRoutingRule.backendAddressPool)
        }
        backendHttpSettings: {
          id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', parWebApplicationFirewallName, requestRoutingRule.backendHttpSetting)
        }
      }
    }]
    enableHttp2: false
    firewallPolicy: {
      id: resWebApplicationFirewallPolicy.id
    }
  }
}

// Output
output webApplicationFirewallId string = resWebApplicationFirewall.id
output webApplicationFirewallName string = resWebApplicationFirewall.name
