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
executeScript 'InstallWinGet.ps1';
executeScript 'PackageManagement.ps1';

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'FileExplorerSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'CreateBoxstarterShortcut.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- YubiKey Authentication ---
executeScript 'YubiKey.ps1';

#--- Windows Dev Essentials
executeScript 'DotNetTools.ps1';
# choco install -y dotpeek # Installer appears to be broken on my machine
# choco install -y linqpad

executeScript 'ConfigureGit.ps1';
choco install -y lepton

#--- Configure Powershell Profile for Powerline and PSReadline ---
executeScript 'ConfigurePowerShell.ps1';

#--- Assorted PowerShellTools ---
executeScript 'PowerShellTools.ps1';
executeScript 'GNU.ps1';

#--- Assorted Dev Tools and Dependencies ---
executeScript 'MiscDevTools.ps1';
# executeScript 'Matlab.ps1';
executeScript 'OpenJDK.ps1';

#--- Administrative Tools ---
executeScript 'RemoteServerAdministrationTools.ps1';
executeScript 'HardwareMonitoring.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'SQLServerManagementStudio.ps1'
executeScript 'NetworkTools.ps1';
executeScript 'RemoteAndLocalFileSystem.ps1';

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
executeScript 'Scientific.ps1';
executeScript 'WindowsPersonalization.ps1';
executeScript 'WindowsPowerUser.ps1';

RefreshEnv;
Start-Sleep -Seconds 1;

# #--- Web Dev Tools ---
# executeScript 'HyperV.ps1';
# # executeScript "Docker.ps1";
# executeScript 'WSL.ps1';

# RefreshEnv;
# Start-Sleep -Seconds 1;

# #--- Microsoft WebDriver ---
# # choco install -y microsoftwebdriver

# RefreshEnv;
# Start-Sleep -Seconds 1;

# #--- Web NodeJS Tools ---
# choco install -y nodejs-lts # Node.js LTS, Recommended for most users
# # choco install -y nodejs # Node.js Current, Latest features
# choco install -y visualstudio2017buildtools
# choco install -y visualstudio2017-workload-vctools
# choco install -y python2 # Node.js requires Python 2 to build native modules

# RefreshEnv;
# Start-Sleep -Seconds 1;

# #--- Machine Learning Tools ---
# executeScript 'GetMLIDEAndTooling.ps1';
# executeScript 'PythonMLTools.ps1';

# try {
# 	Write-Host 'Installing tools inside the WSL distro...'
# 	Ubuntu1804 run apt update -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install ansible -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install git-core -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install git-extras -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install neofetch -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install nodejs -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install python-numpy python-scipy -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install python2.7 python-pip -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install unzip -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run apt install zip -y
# 	Start-Sleep -Seconds 1;
# 	Ubuntu1804 run pip install pandas
# 	Start-Sleep -Seconds 1;
# } catch {
# 	# Skip for now
# }

# #--- DevOps Azure Tools ---
# choco install -y powershell-core
# choco install -y azure-cli
# Install-Module -Force Az
# choco install -y microsoftazurestorageexplorer
# choco install -y terraform

# RefreshEnv;
# Start-Sleep -Seconds 1;

# #--- Gordon 360 Api Workload ---
# choco install -y nuget.commandline
# choco install -y visualstudio2017-workload-netweb

# RefreshEnv;
# Start-Sleep -Seconds 1;

# #--- Column UI Workload ---
# choco install -y visualstudio2019community --package-parameters="'--add Microsoft.VisualStudio.Component.Git'"
# choco install -y visualstudio2019-workload-nativedesktop
# choco install -y visualstudio2019-workload-vctools

# RefreshEnv;
# Start-Sleep -Seconds 1;

# checkout recent projects
executeScript 'GetFavoriteProjects.ps1'

# executeScript 'WindowsTemplateStudio.ps1'; # Possibly Broken
# executeScript 'GetUwpSamplesOffGithub.ps1'; # Possibly Broken

#--- Windows Settings ---
Disable-BingSearch
# Disable-GameBarTips

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
# if ($env:USERDOMAIN | Select-String 'DESKTOP') {
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
Add-Content -Path $SimpleLog -Value 'nerdygriffin_all_in_one' | Out-Null

Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose
Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib-bad') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula
