targetScope = 'subscription'

param parResourceGroupName string
param parLocation sting

resource resResourceGroup 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: parResourceGroupName
  location: parLocation
}

resource resVirtualNetwork 'Microsoft.Network/virtualNetworks@2024-03-01' = {
  scope: resResourceGroup.name
  name: 
  location: resourceGroup().location
}
