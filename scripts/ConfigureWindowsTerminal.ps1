# Replace Windows Terminal settings dir with symlink to OneDrive
$LocalTermSettingsDir = (Join-Path $env:LOCALAPPDATA '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState')
$RemoteTermSettingsDir = (Join-Path $env:OneDrive 'Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState')
if (-Not(Test-Path $RemoteTermSettingsDir)) {
	New-Item -Path $RemoteTermSettingsDir -ItemType Directory -Force
}
if ((Test-Path $LocalTermSettingsDir) -and (-not(Get-Item $LocalTermSettingsDir | Where-Object Attributes -Match ReparsePoint))) {
	$BackupPath = "$RemoteTermSettingsDir-$env:COMPUTERNAME-$(Get-Date -Format "yyyy-MM-dd")"
	if (Test-Path $BackupPath) {
		Remove-Item -Path $BackupPath -Recurse -Force
	}
	New-Item -Path $BackupPath -ItemType Directory -Force
	Copy-Item -Path "$LocalTermSettingsDir\*" -Destination $BackupPath -Force -Recurse
	Remove-Item -Path $LocalTermSettingsDir -Recurse -Force
}
New-Item -Path $LocalTermSettingsDir -ItemType SymbolicLink -Value $RemoteTermSettingsDir -Force
New-Item -Path (Join-Path $env:USERPROFILE 'WindowsTerminalSettings') -ItemType SymbolicLink -Value $LocalTermSettingsDir -Force
