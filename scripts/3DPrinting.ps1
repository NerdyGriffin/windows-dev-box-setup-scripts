# Replace cura settings dir with symlink to server share
$LocalCuraSettingsPath = (Join-Path $env:APPDATA cura)
$RemoteCuraSettingsPath = 'P:\3D Printing\Slicer Settings Sync\cura'
if (Test-Path $LocalCuraSettingsPath) {
	$BackupPath = "$RemoteCuraSettingsPath-$(Get-Date -Format "yyyy-mm-dd")"
	if (Test-Path $BackupPath) {
		Remove-Item -Path $BackupPath -Recurse -Force
	}
	Move-Item -Path $LocalCuraSettingsPath -Destination $BackupPath -Force
}
New-Item -Path $LocalCuraSettingsPath -ItemType SymbolicLink -Value $RemoteCuraSettingsPath -Force

winget install --id=Ultimaker.Cura --exact --silent --accept-package-agreements --accept-source-agreements
