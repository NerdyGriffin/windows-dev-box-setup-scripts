winget install --id=Ryochan7.DS4Windows --exact --silent --accept-package-agreements --accept-source-agreements

#--- Minecraft Mods
winget install --id=PrismLauncher.PrismLauncher --exact --silent --accept-package-agreements --accept-source-agreements

#--- Mods & Cheats
# choco install -y cheatengine # Package no longer found
choco install -y vortex
winget install --id=WeMod.WeMod --exact --silent --accept-package-agreements --accept-source-agreements

# Install python
choco install -y python

# Refresh path
refreshenv

# Update pip
python -m pip install --upgrade pip

powershell -c "Invoke-RestMethod https://github.com/NiceneNerd/ukmm/releases/download/v0.15.0/ukmm-installer.ps1 | Invoke-Expression"

if (Get-Command ukmm -ErrorAction SilentlyContinue) {
	$UKMMPath = $(Resolve-Path (Get-Command ukmm | Select-Object -Expand Source) | Select-Object -Expand Path)
	if (Test-Path $UKMMPath) {
		$UKMMShortcutDest = (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\U-King Mod Manager.lnk')
		$WshShell = New-Object -ComObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut($UKMMShortcutDest)
		$Shortcut.TargetPath = $UKMMPath
		$Shortcut.Save()
	}
}
