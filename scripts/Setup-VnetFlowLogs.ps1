### Register insights provider ###

# Register Microsoft.Insights provider.
Register-AzResourceProvider -ProviderNamespace Microsoft.Insights

### Enable virtual network flow logs ###

# Place the virtual network configuration into a variable.
$vnet = Get-AzVirtualNetwork -Name myVNet -ResourceGroupName myResourceGroup
# Place the storage account configuration into a variable.
$storageAccount = Get-AzStorageAccount -Name myStorageAccount -ResourceGroupName myResourceGroup

# Create a VNet flow log.
New-AzNetworkWatcherFlowLog -Enabled $true -Name myVNetFlowLog -NetworkWatcherName NetworkWatcher_eastus -ResourceGroupName NetworkWatcherRG -StorageId $storageAccount.Id -TargetResourceId $vnet.Id

### Enable virtual network flow logs and traffic analytics ###

# Place the virtual network configuration into a variable.
$vnet = Get-AzVirtualNetwork -Name myVNet -ResourceGroupName myResourceGroup
# Place the storage account configuration into a variable.
$storageAccount = Get-AzStorageAccount -Name myStorageAccount -ResourceGroupName myResourceGroup

# Create a traffic analytics workspace and place its configuration into a variable.
$workspace = New-AzOperationalInsightsWorkspace -Name myWorkspace -ResourceGroupName myResourceGroup -Location EastUS

# Create a VNet flow log.
New-AzNetworkWatcherFlowLog -Enabled $true -Name myVNetFlowLog -NetworkWatcherName NetworkWatcher_eastus -ResourceGroupName NetworkWatcherRG -StorageId $storageAccount.Id -TargetResourceId $vnet.Id -EnableTrafficAnalytics -TrafficAnalyticsWorkspaceId $workspace.ResourceId -TrafficAnalyticsInterval 10

### List all flow logs in a region ###

# Get all flow logs in East US region.
Get-AzNetworkWatcherFlowLog -NetworkWatcherName NetworkWatcher_eastus -ResourceGroupName NetworkWatcherRG | format-table Name

### View virtual network flow log resource ###
# Get the flow log details.
Get-AzNetworkWatcherFlowLog -NetworkWatcherName NetworkWatcher_eastus -ResourceGroupName NetworkWatcherRG -Name myVNetFlowLog