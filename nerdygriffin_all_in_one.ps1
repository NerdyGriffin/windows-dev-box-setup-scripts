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
executeScript 'CreateBoxstarterShortcut.ps1';
executeScript 'ConfigureChocolatey.ps1';
executeScript 'InstallWinGet.ps1';
executeScript 'PackageManagement.ps1';

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
# executeScript 'FileExplorerSettings.ps1';
# executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';

#--- YubiKey Authentication ---
executeScript 'YubiKey.ps1';

executeScript 'ConfigureGit.ps1';

#--- Configure Powershell Profile for Powerline and PSReadline ---
executeScript 'ConfigurePowerShell.ps1';

#--- Assorted PowerShellTools ---
executeScript 'PowerShellTools.ps1';
executeScript 'GNU.ps1';

#--- Assorted Dev Tools and Dependencies ---
executeScript 'MiscDevTools.ps1';
executeScript 'OpenJDK.ps1';

#--- Administrative Tools ---
executeScript 'RemoteServerAdministrationTools.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'SQLServerManagementStudio.ps1'
executeScript 'NetworkTools.ps1';

#--- Setting up programs for typical every-day use
executeScript '3DPrinting.ps1';
executeScript 'Browsers.ps1';
executeScript 'CAD.ps1'
executeScript 'CloudStorage.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'Multimedia.ps1';
executeScript 'NordVPN.ps1';
executeScript 'OfficeTools.ps1';
executeScript 'PasswordManager.ps1';
executeScript 'WindowsPowerUser.ps1';

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
executeScript 'LogitechGaming.ps1';
# executeScript 'CorsairICue.ps1'; # Incompatibility with Logitech Mouse Drivers causes instability on some computers

#--- Remote Desktop Tools
executeScript 'RemoteDesktop.ps1';

#--- Monitoring and Performance Benchmarks ---
executeScript 'HardwareMonitoring.ps1';
executeScript 'BenchmarkUtils.ps1';

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

# Allow the Programs, which run as administrator, to see the Mapped Network Shares
If (-not(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System')) {
	New-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Force | Out-Null
}
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'EnableLinkedConnections' -Type DWord -Value 1

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
Install-WindowsUpdate #-acceptEula
