# Deploy a Web Application Firewall spoke.

### KQL query to list number of attacks based on 'Message'
AzureDiagnostics
| where Category == 'ApplicationGatewayFirewallLog'
| summarize count() by Message
| sort by count_ desc 