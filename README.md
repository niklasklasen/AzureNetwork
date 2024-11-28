# AzureNetwork
Collection of Azure network templates and scripts.

KQL Queries

List least used Azure Firewall Network Rules
AzureDiagnostics
| where Category == 'AZFWNetworkRule'
| summarize count() by Rule_s, RuleCollection_s
| sort by count_ asc 