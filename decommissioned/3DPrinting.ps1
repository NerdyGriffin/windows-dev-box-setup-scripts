# Replace cura settings dir with symlink to server share
$LocalCuraSettingsPath = (Join-Path $env:APPDATA 'cura')
$RemoteCuraSettingsPath = (Join-Path 'Z:\AppData\Roaming' 'cura')
if (-Not(Test-Path $RemoteCuraSettingsPath)) {
	New-Item -Path $RemoteCuraSettingsPath -ItemType Directory -Force
}
if ((Test-Path $LocalCuraSettingsPath)-and (-not(Get-Item $LocalCuraSettingsPath | Where-Object Attributes -Match ReparsePoint))) {
	$BackupPath = "$RemoteCuraSettingsPath-$env:COMPUTERNAME-$(Get-Date -Format "yyyy-MM-dd")"
	if (Test-Path $BackupPath) {
		Remove-Item -Path $BackupPath -Recurse -Force
	}
	New-Item -Path $BackupPath -ItemType Directory -Force
	Copy-Item -Path "$LocalCuraSettingsPath\*" -Destination $BackupPath -Force -Recurse
	Remove-Item -Path $LocalCuraSettingsPath -Recurse -Force
}
New-Item -Path $LocalCuraSettingsPath -ItemType SymbolicLink -Value $RemoteCuraSettingsPath -Force

winget install --id=OpenSCAD.OpenSCAD --exact --silent --accept-package-agreements --accept-source-agreements
winget install --id=Ultimaker.Cura --exact --silent --accept-package-agreements --accept-source-agreements
