targetScope = 'subscription'

// Parameters
param parLocation string
param parResourceGroupName string
param parServerFarmName string
param parFunctionAppName string

// Resources
module modResourceGroup 'br/public:avm/res/resources/resource-group:0.4.0' = {
  name: 'resourceGroupDeployment'
  params: {
    name: parResourceGroupName
    location: parLocation
  }
}

module modServerfarm 'br/public:avm/res/web/serverfarm:0.4.1' = {
  name: 'serverfarmDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    name: parServerFarmName
    kind: 'functionApp'
    skuCapacity: 0
    skuName: 'Y1'
    zoneRedundant: false
  }
}

module modFunctionApp 'br/public:avm/res/web/site:0.13.0' = {
  name: 'siteDeployment'
  scope: resourceGroup(parResourceGroupName)
  dependsOn: [
    modResourceGroup
  ]
  params: {
    kind: 'functionapp,linux'
    name: parFunctionAppName
    serverFarmResourceId: modServerfarm.outputs.resourceId
    basicPublishingCredentialsPolicies: [
        {
        allow: false
        name: 'ftp'
      }
      {
        allow: false
        name: 'scm'
      }
    ]
    httpsOnly: true
    location: modResourceGroup.outputs.location
    publicNetworkAccess: 'Disabled'
    scmSiteAlsoStopped: true
    siteConfig: {
      alwaysOn: false
      ftpsState: 'FtpsOnly'
      healthCheckPath: '/healthz'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'powershell|7.4'
        }
      ]
      minTlsVersion: '1.2'
    }
    vnetContentShareEnabled: true
    vnetImagePullEnabled: true
    vnetRouteAllEnabled: true
  }
}
