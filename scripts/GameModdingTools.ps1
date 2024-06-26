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

# Refresh path
refreshenv

if (-Not(Get-Command bcml -ErrorAction SilentlyContinue)) {
	try {
		pip install bcml
	} catch {
		# Install BCML (Tool for cemu mods)
		Write-Host "'pip install bcml' failed. Note: BCML with Python 3.9+ will not work on Windows until 'pythonnet' is updated."
		Write-Host 'As a workaround, I will now attempt to install Python 3.8 for use with BCML.'

		$python38Installer = (Join-Path $env:USERPROFILE 'Downloads\python-3.8.10-amd64.exe')
		if (-Not(Test-Path $python38Installer)) {
			$source = 'https://www.python.org/ftp/python/3.8.10/python-3.8.10-amd64.exe'
			Write-Verbose 'Downloading Python 3.8 installer...'
			Invoke-WebRequest -Uri $source -OutFile $python38Installer
		}

		Set-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem -Name LongPathsEnabled -Value 1

		Write-Verbose 'Running Python 3.8 installer...'
		Invoke-Expression "$python38Installer /quiet InstallAllUsers=0 PrependPath=1"
		RefreshEnv;
		Start-Sleep -Seconds 1;

		$python38 = (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python38\python.exe')
		if (Test-Path $python38) {
			Write-Verbose 'Installing BCML using Python 3.8'
			Invoke-Expression "$python38 -m pip install --upgrade pip"
			RefreshEnv;
			Start-Sleep -Seconds 1;
			Invoke-Expression "$python38 -m pip install bcml"
			RefreshEnv;
			Start-Sleep -Seconds 1;
		}
	}
}

# Refresh path
refreshenv

if (Get-Command bcml -ErrorAction SilentlyContinue) {
	$BCMLPath = $(Resolve-Path (Get-Command bcml | Select-Object -Expand Source) | Select-Object -Expand Path)
	if (Test-Path $BCMLPath) {
		$BCMLShortcutDest = (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\BCML.lnk')
		$WshShell = New-Object -ComObject WScript.Shell
		$Shortcut = $WshShell.CreateShortcut($BCMLShortcutDest)
		$Shortcut.TargetPath = $BCMLPath
		$Shortcut.Save()
	}
}
