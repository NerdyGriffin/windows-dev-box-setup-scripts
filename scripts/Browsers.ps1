Function Install-WinGetApp {
	param([Parameter(Mandatory = $true, Position = 0)][string]$Id,
		[Parameter(Mandatory = $false, Position = 1)][string]$Source)
	#check if the app is already installed
	$listApp = winget list --exact -q $Id
	if (![String]::Join("", $listApp).Contains($Id)) {
		Write-Host "Installing:" $Id
		if ($Source -ne $null) {
			winget install --exact --silent $Id --source $Source --accept-package-agreements --accept-source-agreements
		} else {
			winget install --exact --silent $Id --accept-package-agreements --accept-source-agreements
		}
		RefreshEnv;
	} else {
		Write-Host "Skipping Install of " $Id
	}
	Start-Sleep -Seconds 1;
}

#--- Browsers ---
# Install-WinGetApp -Id 'Brave.Brave'
choco install -y brave
choco install -y chromium
choco install -y firefox
choco install -y googlechrome
