# Description: Boxstarter Script
# Author: Microsoft
# Common settings for Whittet-Higgins engineering workstations

If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

Disable-UAC

# Get the base URI path from the ScriptToCall value
$bstrappackage = "-bootstrapPackage"
$helperUri = $Boxstarter['ScriptToCall']
$strpos = $helperUri.IndexOf($bstrappackage)
$helperUri = $helperUri.Substring($strpos + $bstrappackage.Length)
$helperUri = $helperUri.TrimStart("'", " ")
$helperUri = $helperUri.TrimEnd("'", " ")
$helperUri = $helperUri.Substring(0, $helperUri.LastIndexOf("/"))
$helperUri += "/scripts"
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
executeScript 'WHFileExplorerSettings.ps1';
executeScript 'WHRemoveDefaultApps.ps1';

#--- Package Manager ---
executeScript 'InstallWinGet.ps1';
executeScript 'PackageManagement.ps1';

#--- Setting up Chocolatey ---
executeScript 'ChocolateyExtensions.ps1';
executeScript 'ChocolateyGUI.ps1';

#--- Windows Privacy Settings ---
executeScript 'WHPrivacySettings.ps1';

#--- Whittet-Higgins Custom Setup ---
executeScript 'WHDisableIPv6.ps1';
executeScript 'WHWorkstation.ps1';
executeScript "WHEngineer.ps1"

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula