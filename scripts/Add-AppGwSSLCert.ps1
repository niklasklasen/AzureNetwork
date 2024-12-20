# Connect to Azure using -AuthScope AzureKeyVaultServiceEndpointResourceId to use the managed identity
Connect-AzAccount -AuthScope AzureKeyVaultServiceEndpointResourceId
# Get the Application Gateway we want to modify
$appgw = Get-AzApplicationGateway -Name "p-waf-agw" -ResourceGroupName "p-waf-rg"
# Specify the resource id to the user assigned managed identity - This can be found by going to the properties of the managed identity
Set-AzApplicationGatewayIdentity -ApplicationGateway $appgw -UserAssignedIdentityId "/subscriptions/178eb97e-2a58-4e6a-81a3-3ad481221fe0/resourcegroups/p-waf-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/p-waf-mi"
# Get the secret ID from Key Vault
$secret = Get-AzKeyVaultSecret -VaultName "p-waf-kv-03" -Name "demo-cert"
$secretId = $secret.Id.Replace($secret.Version, "") # Remove the secret version so Application Gateway uses the latest version in future syncs
# Specify the secret ID from Key Vault 
Add-AzApplicationGatewaySslCertificate -KeyVaultSecretId $secretId -ApplicationGateway $appgw -Name $secret.Name
# Commit the changes to the Application Gateway
Set-AzApplicationGateway -ApplicationGateway $appgw