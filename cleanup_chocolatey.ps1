If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

Disable-UAC

Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose
Get-ChildItem -Path (Join-Path $env:ChocolateyInstall 'lib-bad') | Where-Object -Property Name -Like 'tmp*.tmp' | Remove-Item -Recurse -Force -Verbose

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
