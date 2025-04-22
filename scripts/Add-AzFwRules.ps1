$fwPolicyName = 'firewall-policy'
$fwPolicyResourceGroup = 'firewall-rg'
$fwRuleCollectionGroupName = 'RASK'

$fwPolicy = Get-AzFirewallPolicy -name $fwPolicyName -resourceGroupName $fwPolicyResourceGroup
$fwRuleCollectionGroup = New-AzFirewallPolicyRuleCollectionGroup -Name $fwRuleCollectionGroupName -Priority 100 -FirewallPolicyObject $fwPolicy
$rule = New-AzFirewallPolicyNetworkRule -Name "allow-all-tcp" -Protocol "TCP" -SourceAddress * -DestinationAddress * -DestinationPort *
$fwRuleCollectionFilter = New-AzFirewallPolicyFilterRuleCollection -Name 'NetworkRulesCollection' -Priority 100 -ActionType 'Allow' -Rule $rule
Set-AzFirewallPolicyRuleCollectionGroup -Name $fwRuleCollectionGroup.Name -Priority 100 -RuleCollection @$fwRuleCollectionFilter -FirewallPolicyObject $fwPolicy