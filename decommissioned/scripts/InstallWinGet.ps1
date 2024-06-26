#Install WinGet
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901
$hasPackageManager = Get-AppPackage -name 'Microsoft.DesktopAppInstaller'
if (!$hasPackageManager -or [version]$hasPackageManager.Version -lt [version]"1.10.0.0") {
	"Installing winget Dependencies"
	Add-AppxPackage -Path 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx'

	$releases_url = 'https://api.github.com/repos/microsoft/winget-cli/releases/latest'

	[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
	$releases = Invoke-RestMethod -uri $releases_url
	$latestRelease = $releases.assets | Where { $_.browser_download_url.EndsWith('msixbundle') } | Select -First 1

	"Installing winget from $($latestRelease.browser_download_url)"
	Add-AppxPackage -Path $latestRelease.browser_download_url

	try {
		Invoke-Reboot
	}
	catch {
		<#Do this if a terminating exception happens#>
	}
}
else {
	"winget already installed"
}