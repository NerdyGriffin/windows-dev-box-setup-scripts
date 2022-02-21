Function Install-WinGetApp {
	param([Parameter(Mandatory = $true, Position = 0)][string]$Id,
		[Parameter(Mandatory = $false, Position = 1)][string]$Source)
	#check if the app is already installed
	$listApp = winget list --exact -q $Id
	if (![String]::Join("", $listApp).Contains($Id)) {
		Write-Host "Installing:" $Id
		if ($Source -ne $null) {
			winget install --exact --silent $Id --source $Source --accept-package-agreements --accept-source-agreements
		} else {
			winget install --exact --silent $Id --accept-package-agreements --accept-source-agreements
		}
		RefreshEnv;
	} else {
		Write-Host "Skipping Install of " $Id
	}
	Start-Sleep -Seconds 1;
}

if (([Security.Principal.WindowsPrincipal] `
			[Security.Principal.WindowsIdentity]::GetCurrent() `
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	#--- PowerShell ---
	choco upgrade -y powershell
	choco upgrade -y powershell-core
	refreshenv

	#--- Windows Terminal ---
	Install-WinGetApp -Id 'Microsoft.WindowsTerminal' -Source 'msstore'

	#--- Oh My Posh Environment Variable ---
	[System.Environment]::SetEnvironmentVariable('POSH_THEMES_PATH', '~\AppData\Local\Programs\oh-my-posh\themes')
	refreshenv
}

#--- Enable Powershell Script Execution
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force -ErrorAction Continue
refreshenv

[ScriptBLock]$ScriptBlock = {
	#--- Update all modules ---
	Write-Host 'Updating all modules...'
	Update-Module -ErrorAction SilentlyContinue
	refreshenv
	Start-Sleep -Seconds 1;

	if (-not(Test-Path $PROFILE)) {
		Write-Verbose "`$PROFILE does not exist at $PROFILE`nCreating new `$PROFILE..."
		New-Item -Path $PROFILE -ItemType File -Force
	}

	#--- Prepend a Custom Printed Message to the PowerShell Profile
	Write-Host 'Prepending Custom Message to PowerShell Profile...'
	$ProfileString = 'Write-Output "Loading Custom PowerShell Profile..."'
	if (-not(Select-String -Pattern $ProfileString -Path $PROFILE )) {
		Write-Output 'Attempting to add the following line to $PROFILE :' | Write-Debug
		Write-Output $ProfileString | Write-Debug
		Set-Content -Path $PROFILE -Value ($ProfileString, (Get-Content $PROFILE))
	}

	#--- Install & Configure the Powerline Modules
	try {
		if (([Security.Principal.WindowsPrincipal] `
					[Security.Principal.WindowsIdentity]::GetCurrent() `
			).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
			Write-Host 'Installing Oh-My-Posh - [Dependencies for Powerline]'
			winget install --id=JanDeDobbeleer.OhMyPosh --exact --silent --accept-package-agreements --accept-source-agreements
			refreshenv
		}
		[System.Environment]::SetEnvironmentVariable('POSH_THEMES_PATH', '~\AppData\Local\Programs\oh-my-posh\themes')
		refreshenv
		Write-Host 'Appending Configuration for Powerline to PowerShell Profile...'
		$PowerlineProfile = @(
			'# Dependencies for powerline',
			'oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/microverse-power.omp.json | Invoke-Expression'
		)
		if (-not(Select-String -Pattern $PowerlineProfile[0] -Path $PROFILE )) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $PowerlineProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $PowerlineProfile
		}
		# Install additional Powerline-related packages via chocolatey
		# choco install -y poshgit
		# choco install -y posh-github
		# refreshenv
	} catch {
		Write-Host  'Powerline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Powerline install fails due to error
	}

	#--- Install & Configure the PSReadline Module
	try {
		Write-Host 'Installing PSReadLine -- [Bash-like CLI features and Optional Dependency for Powerline]'
		if (-not(Get-Module -ListAvailable -Name PSReadLine)) {
			Install-Module -Name PSReadLine -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'PSReadLine' already installed" }
		refreshenv
		Write-Host 'Appending Configuration for PSReadLine to PowerShell Profile...'
		$PSReadlineProfile = @(
			'# Customize PSReadline to make PowerShell behave more like Bash',
			'Import-Module PSReadLine',
			'Set-PSReadLineOption -EditMode Emacs -HistoryNoDuplicates -HistorySearchCursorMovesToEnd',
			# 'Set-PSReadLineOption -BellStyle Audible -DingTone 512',
			'# Creates an alias for ls like I use in Bash',
			'Set-Alias -Name v -Value Get-ChildItem'
		)
		if (-not(Select-String -Pattern $PSReadlineProfile[0] -Path $PROFILE)) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $PSReadlineProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $PSReadlineProfile
		}
	} catch {
		Write-Host  'PSReadline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if PSReadline install fails due to errors
	}

	#--- Import Chocolatey Modules
	if (([Security.Principal.WindowsPrincipal] `
				[Security.Principal.WindowsIdentity]::GetCurrent() `
		).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		Write-Host 'Appending Configuration for Chocolatey to PowerShell Profile...'
		$ChocolateyProfile = @(
			'# Chocolatey profile',
			'$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"',
			'if (Test-Path($ChocolateyProfile)) {'
			'	Import-Module "$ChocolateyProfile"'
			'}'
		)
		if (-not(Select-String -Pattern $ChocolateyProfile[0] -Path $PROFILE)) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $ChocolateyProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $ChocolateyProfile
		}
	}

	# #--- Import Boxstarter Modules
	# Write-Host 'Appending Configuration for Boxstarter to PowerShell Profile...'
	# $BoxstarterProfile = @(
	# 	'# Boxstarter modules',
	# 	'# Import the Chocolatey module first so that $Boxstarter properties',
	# 	'# are initialized correctly and then import everything else.',
	# 	'if (Test-Path("\\files.nerdygriffin.net\Boxstarter")) {',
	# 	'	$BoxstarterInstall = "\\files.nerdygriffin.net\Boxstarter"',
	# 	'} elseif (Test-Path("D:\Boxstarter")) {',
	# 	'	$BoxstarterInstall = "D:\Boxstarter"',
	# 	'}',
	# 	'Import-Module $BoxstarterInstall\Boxstarter.Chocolatey\Boxstarter.Chocolatey.psd1 -DisableNameChecking -ErrorAction SilentlyContinue',
	# 	'Resolve-Path $BoxstarterInstall\Boxstarter.*\*.psd1 |',
	# 	'	% { Import-Module $_.ProviderPath -DisableNameChecking -ErrorAction SilentlyContinue }',
	# 	'Import-Module $BoxstarterInstall\Boxstarter.Common\Boxstarter.Common.psd1 -Function Test-Admin'
	# )
	# if (-not(Select-String -Pattern $BoxstarterProfile[0] -Path $PROFILE)) {
	# 	Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
	# 	Write-Output $BoxstarterProfile | Write-Debug
	# 	Add-Content -Path $PROFILE -Value $BoxstarterProfile
	# }

	#--- Install the Pipeworks Module
	try {
		Write-Host 'Installing Pipeworks -- [CLI Tools for PowerShell]'
		Write-Host 'Description: PowerShell Pipeworks is a framework for writing Sites and Software Services in Windows PowerShell modules.'
		if (-not(Get-Module -ListAvailable -Name Pipeworks)) {
			Install-Module -Name Pipeworks -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'Pipeworks' already installed" }
		refreshenv
	} catch {
		Write-Host 'Pipeworks failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Pipeworks install fails due to errors
	}

	#--- Install the CredentialManager Module
	try {
		Write-Host 'Installing CredentialManager'
		Write-Host 'Description: Provides access to credentials in the Windows Credential Manager.'
		if (-not(Get-Module -ListAvailable -Name CredentialManager)) {
			Install-Module -Name CredentialManager
		} else { Write-Host "Module 'CredentialManager' already installed" }
		refreshenv
	} catch {
		Write-Host  'CredentialManager failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if CredentialManager install fails due to errors
	}

	#--- Update all modules ---
	Write-Host 'Updating all modules...'
	Update-Module -ErrorAction SilentlyContinue
} # End of $ScriptBlock

# Run the script block in PowerShell
powershell -Command $ScriptBlock

# Run the script block in PowerShell Core
pwsh -Command $ScriptBlock

$WindowsTerminalSettingsDir = (Join-Path $env:LOCALAPPDATA '\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState')
$SymLinkPath = (Join-Path $env:USERPROFILE 'WindowsTerminalSettings')
if (Test-Path $WindowsTerminalSettingsDir) {
	if ((-not(Test-Path $SymLinkPath)) -or (-not(Get-Item $SymLinkPath | Where-Object Attributes -Match ReparsePoint))) {
		New-Item -Path $SymLinkPath -ItemType SymbolicLink -Value $WindowsTerminalSettingsDir -Force -Verbose
	}
	$RemoteBackup = '\\files.nerdygriffin.net\backup\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\.git'
	if ((Test-Path $RemoteBackup) -and (-not(Test-Path (Join-Path $WindowsTerminalSettingsDir '.git')))) {
		$PrevLocation = Get-Location
		Set-Location -Path $RemoteBackup
		git fetch; git pull;
		Copy-Item -Path $RemoteBackup -Destination (Join-Path $WindowsTerminalSettingsDir '.git')
		Set-Location -Path $PrevLocation
	}
}

[System.Environment]::SetEnvironmentVariable('PYTHONSTARTUP', (Join-Path $env:USERPROFILE '.pystartup'))
