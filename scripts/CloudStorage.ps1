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

# choco install -y google-drive-file-stream
# Install-WinGetApp -Id 'Google.Drive'
# choco install -y megasync

Install-WinGetApp -Id 'Nextcloud.NextcloudDesktop'

# $NextcloudCheck = $(choco list -l nextcloud-client | Select-String -Pattern 'nextcloud-client')
# if (-not($NextcloudCheck)) {
# 	choco install -y nextcloud-client
# }

# $NextcloudPlaceholder = Join-Path (Get-LibraryNames).Desktop 'nextcloud-placeholder'
# if (Test-Path $NextcloudPlaceholder) {
# 	Remove-Item -Path $NextcloudPlaceholder
# } else {
# 	New-Item -Path $NextcloudPlaceholder -ItemType File -Value 'This is just a marker for the script. You may delete this file'
# 	choco install -y nextcloud-client
# }
