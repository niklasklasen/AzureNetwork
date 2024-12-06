// Parameters
param location string
param vnetName string
param vnetAddressPrefix string
param vnetDnsServers array
param subnets array


// Resource
resource vnet 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    dhcpOptions: {
      dnsServers: vnetDnsServers
    }
    encryption: {
      enabled: true
    }
    subnets: [ for subnet in subnets: {
        name: subnet.name
        properties: {
          addressPrefix: subnet.addressPrefix
          networkSecurityGroup: {
            location: location
            properties: {
              securityRules: [
                {
                  name: 'default-Deny-All'
                  properties:{
                    access: 'Deny'
                    direction: 'Inbound'
                    priority: 4000
                    protocol: '*'
                    sourceAddressPrefix: '*'
                    sourcePortRange: '*'
                    destinationAddressPrefix: '*'
                    destinationPortRange: '*'
                  }
                }
              ]
            }
          }
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnets array = vnet.properties.subnets
