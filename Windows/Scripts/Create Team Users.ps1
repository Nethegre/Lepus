# Specifty company, AD domain, and email domain

$companyName = "TeamC"
$domain = "teamc.ad.lepus.com"
$emailDomain = "teamc.lepus.com"
$defaultPassword = "NKUnku12"

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

# Do magic

For ($i=1; $i -le 10; $i++)
{
	$name = "Team User $i"

	$name_array = $name -split ' '
	$firstName = $name_array[0]
	$lastName = $name_array[1]
	$userName = ($firstName + $lastName + $i).tolower()
	$emailAddress = $userName + "@" + $emailDomain

	New-ADUser `
		-Name $name `
		-ChangePasswordAtLogon $false `
		-Description "Team User" `
		-Path "OU=Active Users,OU=Users,OU=$companyName,$DN" `
		-SamAccountName $userName `
		-GivenName $firstName `
		-Surname $lastName `
		-DisplayName $name `
		-Enabled $true `
		-AccountPassword (ConvertTo-SecureString -String $defaultPassword -AsPlainText -Force) `
		-EmailAddress $emailAddress `
		-UserPrincipalName $emailAddress `
		-PasswordNeverExpires $true
		
	Add-ADGroupMember "Domain Admins" $userName
}
