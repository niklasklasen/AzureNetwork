using 'main.bicep'

param parLocation = 'swedencentral'
param parResourceGroupName = 'p-dnsAutomation-rg'
param parEventGridSystemTopicName = 'p-dnsAutomation-egst'
param parCreateFunctionResourceId = '/subscriptions/178eb97e-2a58-4e6a-81a3-3ad481221fe0/resourceGroups/p-dnsAutomation-rg/providers/Microsoft.Web/sites/p-dnsAutomation-app/functions/createDnsRecord'
param parDeleteFunctionResourceId = '/subscriptions/178eb97e-2a58-4e6a-81a3-3ad481221fe0/resourceGroups/p-dnsAutomation-rg/providers/Microsoft.Web/sites/p-dnsAutomation-app/functions/deleteDnsRecord'
