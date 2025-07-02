using 'main.bicep'

param parLocation = 'swedencentral'
param parResourceGroupName = 'rg-shared-waf-pr-sece-001'
param parKeyVaultName = 'kv-shared-waf-pr-sece-001'
param parEnablePurgeProtection = false
param parManagedIdentityName = 'mi-shared-waf-pr-sece-001'
param parRouteTableName = 'rt-shared-waf-pr-sece-001'
param parVnetName = 'vnet-shared-waf-pr-sece-001'
param parVnetAddressPrefix = ['10.0.1.0/24']
param parPublicIpAddressName = 'pip-agw-shared-waf-pr-sece-001'
param parWebApplicationFirewallPolicyName = 'waf-shared-waf-pr-sece-001'
param parApplicationGatewayName = 'agw-shared-waf-pr-sece-001'
param parNsgName = 'nsg-shared-waf-pr-sece-001'
