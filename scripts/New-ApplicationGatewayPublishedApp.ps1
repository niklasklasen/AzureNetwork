# Variables - set these to match your environment
$resourceGroupName = "p-waf-rg"
$appGwName = "p-waf-agw"
$location = "SwedenCentral"

# Names for the new components
$listenerName = "PS-Listener2"
$frontendIPConfigName = "frontendIPConfig"
$frontendPortName = "appGwFrontendPort-80"
$backendPoolName = "PS-BackendPool2"
$httpSettingName = "PS-BackendSetting2"
$routingRuleName = "PS-Rule2"
$routingRulePriority = 160
$hostName = @("test1.contoso.com", "test2.contoso.com")

# Backend pool targets
$backendIPAddresses = @("10.0.1.6", "10.0.1.7")

# Get the existing Application Gateway
$appGw = Get-AzApplicationGateway -Name $appGwName -ResourceGroupName $resourceGroupName

# 1. Create frontend port
$frontendPort = New-AzApplicationGatewayFrontendPort -Name $frontendPortName -Port 80

# 2. Get Frontend IP Configuration
$frontendIpConfiguration = Get-AzApplicationGatewayFrontendIPConfig -Name $frontendIPConfigName -ApplicationGateway $appGw

# 2. Create listener
$listener = New-AzApplicationGatewayListener `
    -Name $listenerName `
    -Protocol Http `
    -FrontendIPConfiguration $frontendIpConfiguration `
    -FrontendPort $frontendPort `
    -HostName $hostName

# 3. Create backend address pool
$backendPool = New-AzApplicationGatewayBackendAddressPool -Name $backendPoolName -BackendIPAddresses $ip

# 4. Create backend HTTP settings
$httpSetting = New-AzApplicationGatewayBackendHttpSetting `
    -Name $httpSettingName `
    -Port 80 `
    -Protocol Http `
    -CookieBasedAffinity Disabled

# 5. Create routing rule
$rule = New-AzApplicationGatewayRequestRoutingRule `
    -Name $routingRuleName `
    -RuleType Basic `
    -HttpListener $listener `
    -BackendAddressPool $backendPool `
    -BackendHttpSettings $httpSetting `
    -Priority $routingRulePriority

# 6. Add the new components to the Application Gateway
$appGw.FrontendPorts.Add($frontendPort)
$appGw.HttpListeners.Add($listener)
$appGw.BackendAddressPools.Add($backendPool)
$appGw.BackendHttpSettingsCollection.Add($httpSetting)
$appGw.RequestRoutingRules.Add($rule)

# 7. Update the Application Gateway
Set-AzApplicationGateway -ApplicationGateway $appGw

Write-Host "New components added to the Application Gateway: $appGwName"


$fports = Get-AzApplicationGatewayFrontendPort -ApplicationGateway $appGw 
$fports.