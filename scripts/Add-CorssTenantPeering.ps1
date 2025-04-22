connect-azaccount -tenant '69b863e3-480a-4ee9-8bd0-20a8adb6909b' -subscription '3c2e2971-acc5-4f9d-b269-95d86d2d9096'
$remote = Get-AzVirtualNetwork -Name 'vnet-HEC42-IKS' -ResourceGroupName 'HEC42-IKS-northeurope-1'

connect-azaccount -tenant 'a33c6ac4-a52e-45c5-af07-b972df9bd004' -subscription '74081beb-fd80-494d-b5e7-981bb181e150'
$rt1 = Get-AzVHubRouteTable -ResourceGroupName 'rg-vwan-pr-global-001' -VirtualHubName 'vwh-conhub-pr-euno-001' -Name 'defaultRouteTable'  
$rt2 = Get-AzVHubRouteTable -ResourceGroupName 'rg-vwan-pr-global-001' -VirtualHubName 'vwh-conhub-pr-euno-001' -Name "noneRouteTable"  
$routingconfig = New-AzRoutingConfiguration -AssociatedRouteTable $rt1.Id -Label @("none") -Id @($rt2.Id)  
New-AzVirtualHubVnetConnection -ResourceGroupName 'rg-vwan-pr-global-001' -VirtualHubName 'vwh-conhub-pr-euno-001' -Name 'HEC42-IKS-northeurope-1' -RemoteVirtualNetwork $remote -RoutingConfiguration $routingconfig  