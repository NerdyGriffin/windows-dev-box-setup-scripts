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


#--- Windows 10 Tools ---
choco install -y autoruns
# choco install -y everything
# choco install -y mousewithoutborders
Install-WinGetApp -Id 'Microsoft.PowerToys'
choco install -y plasso --ignore-checksums # The checksums are never correct on this package, that is to be expected
choco install -y reshack
choco install -y shutup10
choco install -y sharex
choco install -y sdio
choco install -y tcpview --ignore-checksums
# choco install -y winaero-tweaker
# choco install -y xyplorer

# Add a custom registry entry for running PowerToys at startup
$PowerToysCommand = """$env:ProgramFiles\PowerToys\PowerToys.exe"""
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name PowerToys -Value $PowerToysCommand

# Add a custom registry entry for running Sharex at startup
$SharexCommand = """$env:ProgramFiles\Sharex\sharex.exe"" -silent"
Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name Sharex -Value $SharexCommand
Set-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name Sharex -Value $SharexCommand
# We want Sharex to always startup BEFORE OneDrive (to prevent OneDrive from hooking the "print screen" hotkey)
