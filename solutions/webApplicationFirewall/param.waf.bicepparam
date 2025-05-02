using 'main.bicep'

param parLocation = 'swedencentral'
param parResourceGroupName = 'p-waf-rg'
param parKeyVaultName = 'p-waf-kv-01'
param parEnablePurgeProtection = false
param parManagedIdentityName = 'p-waf-mi'
param parRouteTableName = 'p-waf-rt'
param parVnetName = 'p-waf-vnet'
param parVnetAddressPrefix = ['10.0.1.0/24']
param parPublicIpAddressName = 'p-waf-pip'
param parWebApplicationFirewallPolicyName = 'p-waf-pol'
param parApplicationGatewayName = 'p-waf-agw'
