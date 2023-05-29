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

#--- Package Manager ---
executeScript 'ConfigureChocolatey.ps1';
executeScript 'InstallWinGet.ps1';

#--- Setting up Windows ---
executeScript 'FileExplorerSettings.ps1';

#--- Create symbolic links to game install locations
executeScript 'GameSymlinks.ps1';

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
# if ($env:COMPUTERNAME | Select-String 'DESKTOP') {
executeScript 'GameLaunchers.ps1';
# } else {
# 	executeScript 'MinimalGameLaunchers.ps1';
# }

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
Add-Content -Path $SimpleLog -Value 'nerdygriffin_gaming' | Out-Null

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
