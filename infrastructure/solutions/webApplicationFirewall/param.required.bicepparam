using 'main.bicep'

// General Parameters
param environmentType = 't'
param solutionName = 'waf'
param regionShortName = 'sec'
// Resource Group Parameters 
param rgLocation = 'swedencentral'
// Virtual Network Parameters
param vnetAddressPrefixes = [
  '10.0.1.0/24'
]
param snetAddressPrefix = '10.0.1.0/25'

// Application Gateway parameters
param parWebApplicationFirewallRules = {

frontendPorts: [
  {
    name: 'port_80'
    port: 80
  }
]

backendAddressPools: [
  {
    name: 'myBackendPool'
    backendAddresses: [
      {
        ipAddress: '10.162.4.4'
      }
    ]
  }
]

backendHttpSettingsCollection: [
  {
    name: 'myHTTPSetting'
    port: 80
    protocol: 'Http'
    cookieBasedAffinity: 'Disabled'
  }
]

httpListeners: [
  {
    name: 'myListener'
    frontendPort: 'port_80'
    protocol: 'Http'
    requireServerNameIndication: false
  }
]

requestRoutingRules: [
  {
    name: 'myRoutingRule'
    ruleType: 'Basic'
    priority: 10
    httpListener: 'myListener'
    backendAddressPool: 'myBackendPool'
    backendHttpSetting: 'myHTTPSetting'
  }
]

}
