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

if (-not($env:USERDOMAIN | Select-String 'LAPTOP')) {
	# Do nothing if Enable-RemoteDesktop fails, because it will fail if RemoteDesktop is already enabled
	try { Enable-RemoteDesktop } catch {}
}

#--- Setting up Windows ---
executeScript 'SystemConfiguration.ps1';
executeScript 'DisableSleepIfVM.ps1';
executeScript 'FileExplorerSettings.ps1';
executeScript 'RemoveDefaultApps.ps1';
executeScript 'CommonDevTools.ps1';
executeScript 'WindowsPowerUser.ps1';

#--- Setting up Chocolatey
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- Administrative Tools ---
executeScript 'HardwareMonitoring.ps1';
executeScript 'FileAndStorageUtils.ps1';
executeScript 'SQLServerManagementStudio.ps1'
executeScript 'NetworkTools.ps1';
executeScript 'RemoteAndLocalFileSystem.ps1';

executeScript 'UnofficialChocolateyTools.ps1';

Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 >> (Join-Path $env:USERPROFILE '\Desktop\boxstarter-failures.log')

#--- reenabling critial items ---
Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

$SimpleLog = (Join-Path $env:USERPROFILE '\Desktop\last-installed.log')
if (-not(Test-Path $SimpleLog)) {
	New-Item -Path $SimpleLog -ItemType File | Out-Null
}
Add-Content -Path $SimpleLog -Value 'nerdygriffin_sysadmin'
