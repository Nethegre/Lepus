# Create AD Structure

# Specifty company, AD domain, and email domain

$companyName = "TeamC"
$domain = "teamc.ad.lepus.com"
$emailDomain = "teamc.lepus.com"

# Construct DN
$domain_array = $domain -split '\.'
$DN = ""
Foreach ($domain_component in $domain_array)
{
	$DN = $DN + "DC=" + $domain_component
	
	if ( !($domain_component -eq $domain_array[-1]) )
	{
		$DN = $DN + ","
	}
}

New-ADOrganizationalUnit -Name $companyName

New-ADOrganizationalUnit -Name "Users" -Path "OU=$companyName,$DN"
New-ADOrganizationalUnit -Name "Disabled Users" -Path "OU=Users,OU=$companyName,$DN"
New-ADOrganizationalUnit -Name "Active Users" -Path "OU=Users,OU=$companyName,$DN"

New-ADOrganizationalUnit -Name "Groups" -Path "OU=$companyName,$DN"

New-ADOrganizationalUnit -Name "Computers" -Path "OU=$companyName,$DN"
New-ADOrganizationalUnit -Name "Servers" -Path "OU=Computers,OU=$companyName,$DN"
New-ADOrganizationalUnit -Name "Terminal Server" -Path "OU=Servers,OU=Computers,OU=$companyName,$DN"
New-ADOrganizationalUnit -Name "Workstations" -Path "OU=Computers,OU=$companyName,$DN"

# Redirect computers and users to their new OUs
redircmp "OU=Workstations,OU=Computers,OU=$companyName,$DN"
redirusr "OU=Active Users,OU=Users,OU=$companyName,$DN"

# Add the email domain as a UPN suffix

Get-ADForest | Set-ADForest -UPNSuffixes @{add=$emailDomain}

# Set PDC to sync from external time source
w32tm /config /update /manualpeerlist:"us.pool.ntp.org,0x8" /syncfromflags:MANUAL

# Enable AD recycle bin
Enable-ADOptionalFeature -Identity "CN=Recycle Bin Feature,CN=Optional Features,CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$DN" -Scope ForestOrConfigurationSet -Target $domain