# Description: Boxstarter Script
# Author: Christian Kunis (NerdyGriffin)
# Common settings for multi-purpose development

If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

Disable-UAC

# Get the base URI path from the ScriptToCall value
$bstrappackage = '-bootstrapPackage'
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", ' ')
$helperUri = $helperUri.TrimEnd("'", ' ')
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf('/'))
$helperUri += '/scripts'
Write-Host "helper script base URI is $helperUri"

function drawLine { Write-Host '------------------------------' }

function executeScript {
	Param ([string]$script)
	drawLine;
	Write-Host "executing $helperUri/$script ..."
	Invoke-Expression ((New-Object net.webclient).DownloadString("$helperUri/$script")) -ErrorAction Continue
	drawLine;
	RefreshEnv;
	Start-Sleep -Seconds 1;
}

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

#--- Powershell Module Repository
Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

#--- Package Manager ---
executeScript 'ConfigureChocolatey.ps1';

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
# executeScript 'FileExplorerSettings.ps1';
executeScript 'CustomFileExplorerSettings.ps1'
# executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools-WinGet.ps1';
Set-TimeZone -Id "Eastern Standard Time"

#--- YubiKey Authentication ---
executeScript 'YubiKey.ps1';

#--- Configure Git ---
executeScript 'ConfigureGit.ps1';

#--- Configure Powershell Profile for Powerline and PSReadline ---
executeScript 'ConfigurePowerShell.ps1';

#--- Administrative Tools ---
executeScript 'WindowsADK.ps1';
executeScript 'RemoteServerAdministrationTools.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'SQLServerManagementStudio.ps1'
executeScript 'NetworkTools.ps1';

#--- Setting up programs for typical every-day use
executeScript 'Browsers.ps1';
executeScript 'CAD.ps1'
executeScript 'CloudStorage.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'Multimedia.ps1';
executeScript 'NordVPN.ps1';
executeScript 'OfficeTools.ps1';
executeScript 'PasswordManager.ps1';
executeScript 'WindowsPowerUser.ps1';
winget install --id=Rem0o.FanControl --exact --silent --accept-package-agreements --accept-source-agreements

RefreshEnv;
Start-Sleep -Seconds 1;

# checkout recent projects
executeScript 'GetFavoriteProjects.ps1'

#--- Windows Settings ---
# Disable-BingSearch
# Disable-GameBarTips

#--- Graphics Driver Support
executeScript 'NvidiaGraphics.ps1';

#--- Customization Software for Gaming Peripherals
winget install --id=WhirlwindFX.SignalRgb --exact --silent --accept-package-agreements --accept-source-agreements
winget install --id=Logitech.OptionsPlus --exact --silent --accept-package-agreements --accept-source-agreements
winget install --id=Logitech.LGS --exact --silent --accept-package-agreements --accept-source-agreements
# Incompatibility of iCUE with Logitech Mouse Drivers causes instability on some computers
# winget install --id=Corsair.iCUE.4 --exact --silent --accept-package-agreements --accept-source-agreements

#--- Game Launchers ---
executeScript 'GameLaunchers.ps1';

#--- Game Modding Tools ---
executeScript 'GameModdingTools.ps1';

#--- Disable Sticky keys prompt ---
# Based on https://github.com/ChrisTitusTech/win10script
Write-Output 'Disabling Sticky keys prompt...'
Set-ItemProperty -Path 'HKCU:\Control Panel\Accessibility\StickyKeys' -Name 'Flags' -Type String -Value '506'

#--- Service & Registry Tweaks for Origin with Mapped Network Drives

# Disable the "Origin Client Service" to force Origin to execute downloads as Administrator of your User rather than execute under the SYSTEM user account
Get-Service -Name 'Origin Client*' | Set-Service -StartupType Disabled

#--- Parse Boxstarter log for failed package installs ---
executeScript 'ParseBoxstarterLog.ps1';

$SimpleLog = (Join-Path ((Get-LibraryNames).Desktop) '\last-installed.log')
if (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File | Out-Null
}
Add-Content -Path $SimpleLog -Value 'nerdygriffin_all_in_one' | Out-Null

Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose -ErrorAction SilentlyContinue
Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib-bad') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose -ErrorAction SilentlyContinue

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
try {
	Install-WindowsUpdate -acceptEula
} catch {
	try {
		Install-WindowsUpdate
	} catch {
		# Do nothing
	}
}
