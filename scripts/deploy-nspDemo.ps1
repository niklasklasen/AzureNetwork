connect-azaccount 

# Register the Microsoft.Network resource provider
Register-AzResourceProvider -ProviderNamespace Microsoft.Network


# Install the Az.Tools.Installer module    
Install-Module -Name Az.Tools.Installer -Repository PSGallery

# Create a resource group
$rgParams = @{
    Name = "demo-nsp-rg"
    Location = "swedencentral"
}
New-AzResourceGroup @rgParams

# Create a key vault
$keyVaultName = "demo-nsp-$(Get-Random)-kv"
$keyVaultParams = @{
    Name = $keyVaultName
    ResourceGroupName = $rgParams.Name
    Location = $rgParams.Location
}
$keyVault = New-AzKeyVault @keyVaultParams

# Create a network security perimeter
$nsp = @{ 
    Name = 'demo-nsp' 
    location = 'swedencentral' 
    ResourceGroupName = $rgParams.name  
    }

$demoNSP=New-AzNetworkSecurityPerimeter @nsp
$nspId = $demoNSP.Id

# Create a new profile

$nspProfile = @{ 
    Name = 'nsp-profile' 
    ResourceGroupName = $rgParams.name 
    SecurityPerimeterName = $nsp.name 
    }

$demoProfileNSP=New-AzNetworkSecurityPerimeterProfile @nspprofile

# Associate the PaaS resource with the above created profile

$nspAssociation = @{ 
    AssociationName = 'nsp-association' 
    ResourceGroupName = $rgParams.name 
    SecurityPerimeterName = $nsp.name 
    AccessMode = 'Learning'  
    ProfileId = $demoProfileNSP.Id 
    PrivateLinkResourceId = $keyVault.ResourceID
    }

New-AzNetworkSecurityPerimeterAssociation @nspassociation | format-list

# Update the association to enforce the access mode
$updateAssociation = @{ 
    AssociationName = $nspassociation.AssociationName 
    ResourceGroupName = $rgParams.name 
    SecurityPerimeterName = $nsp.name 
    AccessMode = 'Enforced'
    }
Update-AzNetworkSecurityPerimeterAssociation @updateAssociation | format-list