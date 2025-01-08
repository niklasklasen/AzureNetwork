targetScope = 'resourceGroup'

// Parameters
param firewallPolicyName string

param ruleCollectionGroups array

// Resources

resource azureFirewallPolicy 'Microsoft.Network/firewallPolicies@2024-03-01' existing = {
  name: firewallPolicyName
}

resource firewallRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2024-03-01' = [ for ruleCollectionGroup in ruleCollectionGroups: {
    name: ruleCollectionGroup.ruleCollectionGroupName
    parent: azureFirewallPolicy
    properties: {
      priority: ruleCollectionGroup.ruleCollectionGroupPriority
      ruleCollections: [ for ruleCollection in ruleCollectionGroup.ruleCollections: {
          ruleCollectionType: ruleCollection.ruleCollectionType
          action: {
            type: ruleCollection.ruleCollectionAction
          }
          name: ruleCollection.ruleCollectionName
          priority: ruleCollection.ruleCollectionPriority
          rules: ruleCollection.rules
        }
      ]
    }
  }
]
