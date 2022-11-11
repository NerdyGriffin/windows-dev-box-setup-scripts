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

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'FileExplorerSettings.ps1';
# executeScript 'TaskbarSettings.ps1';
executeScript 'DisableSleepIfVM.ps1';
executeScript 'CreateBoxstarterShortcut.ps1';

#--- Package Manager ---
executeScript 'InstallWinGet.ps1';

#--- YubiKey Authentication ---
executeScript 'YubiKey.ps1';

#--- Graphics Driver Support
executeScript 'NvidiaGraphics.ps1';

#--- Setting up programs for typical every-day use
executeScript 'Browsers.ps1';
executeScript 'CloudStorage.ps1';
executeScript 'CommunicationApps.ps1';
executeScript 'Multimedia.ps1';
executeScript 'NordVPN.ps1';
executeScript 'OfficeTools.ps1';
executeScript 'PasswordManager.ps1';
executeScript 'Scientific.ps1';
executeScript 'WindowsPersonalization.ps1';
executeScript 'WindowsPowerUser.ps1';

#--- Custom sync wallpaper folder from file server ---
executeScript 'WallpaperSync.ps1';

#--- Windows Settings ---
Disable-BingSearch
# Disable-GameBarTips

#--- Parse Boxstarter log for failed package installs ---
executeScript 'ParseBoxstarterLog.ps1';

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

$MackieDriverSetupExe = '\\files.nerdygriffin.net\personal\Downloads\Mackie_USB_Driver_v4_67_0\Mackie_USB_Driver_Setup.exe'
If (Test-Path $MackieDriverSetupExe) {
	Write-Verbose 'Attempt installing driver for Mackie mixer board'
	Invoke-Expression $MackieDriverSetupExe
}

$SimpleLog = (Join-Path ((Get-LibraryNames).Desktop) '\last-installed.log')
If (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File | Out-Null
}
Add-Content -Path $SimpleLog -Value 'nerdygriffin_daily_driver' | Out-Null
