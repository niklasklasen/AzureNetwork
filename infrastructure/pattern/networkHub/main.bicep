

// Create Virtual WAN
module virtualWan 'br/public:avm/res/network/virtual-wan:0.3.0' = {
  name: 
  params: {
    name: 
  }
}

module hubVirtualNetwork 'br/public:avm/res/network/virtual-network:0.5.0' = [
  for (hub, index) in items(hubVirtualNetworks ?? {}): {
    name: '${uniqueString(deployment().name, location)}-${hub.key}-nvn'
    params: {
      // Required parameters
      name: hub.key
      addressPrefixes: hub.value.addressPrefixes
      // Non-required parameters
      ddosProtectionPlanResourceId: hub.value.?ddosProtectionPlanResourceId ?? ''
      diagnosticSettings: hub.value.?diagnosticSettings ?? []
      dnsServers: hub.value.?dnsServers ?? []
      enableTelemetry: hub.value.?enableTelemetry ?? true
      flowTimeoutInMinutes: hub.value.?flowTimeoutInMinutes ?? 0
      location: hub.value.?location ?? ''
      lock: hub.value.?lock ?? {}
      roleAssignments: hub.value.?roleAssignments ?? []
      subnets: hub.value.?subnets ?? []
      tags: hub.value.?tags ?? {}
      vnetEncryption: hub.value.?vnetEncryption ?? false
      vnetEncryptionEnforcement: hub.value.?vnetEncryptionEnforcement ?? ''
    }
  }
]
