if (([Security.Principal.WindowsPrincipal] `
			[Security.Principal.WindowsIdentity]::GetCurrent() `
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	#--- PowerShell ---
	choco upgrade -y powershell
	choco upgrade -y powershell-core
	choco upgrade -y winget
	refreshenv

	# #--- Oh My Posh Environment Variable ---
	# [System.Environment]::SetEnvironmentVariable('POSH_THEMES_PATH', '~\AppData\Local\Programs\oh-my-posh\themes')
	# refreshenv
}

#--- Enable Powershell Script Execution
try { Set-ExecutionPolicy Bypass -Scope CurrentUser -Force } catch {} # Do nothing if blocked from Group Policy
refreshenv

[ScriptBLock]$ScriptBlock = {
	try { refreshenv } catch { Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1 }

	if ((Get-CimInstance Win32_OperatingSystem).BuildNumber -lt 17763) {
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
	} else {
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::SystemDefault
	}
	Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue

	#--- Powershell Module Repository
	Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted

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
			'if (!(Get-Module PSReadLine -ErrorAction SilentlyContinue)) { Import-Module PSReadLine }',
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
		Write-Host 'PSReadline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if PSReadline install fails due to errors
	}

	#--- Install the PSWindowsUpdate Module
	try {
		Write-Host 'Installing PSWindowsUpdate'
		if (-not(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
			Install-Module -Name PSWindowsUpdate -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'PSWindowsUpdate' already installed" }
		refreshenv
	} catch {
		Write-Host 'PSWindowsUpdate failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if PSWindowsUpdate install fails due to errors
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
			'    Import-Module "$ChocolateyProfile"'
			'}'
		)
		if (-not(Select-String -Pattern $ChocolateyProfile[0] -Path $PROFILE)) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $ChocolateyProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $ChocolateyProfile
		}
	}

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
		Write-Host 'CredentialManager failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if CredentialManager install fails due to errors
	}

	#--- Install & Configure the Powerline Modules
	try {
		Write-Host 'Installing Oh-My-Posh - [Dependencies for Powerline]'
		try {
			winget install JanDeDobbeleer.OhMyPosh --source winget
		} catch {
			Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
		}
		try { oh-my-posh font install meslo } catch {}
		refreshenv
		Write-Host 'Appending Configuration for Powerline to PowerShell Profile...'
		$PowerlineProfile = @(
			'# Dependencies for powerline',
			# 'oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/microverse-power.omp.json | Invoke-Expression'
			'oh-my-posh init $(oh-my-posh get shell) --eval --config ''microverse-power'' | Invoke-Expression'
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
		Write-Host 'Powerline failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Powerline install fails due to error
	}

	Get-Content -Path $PROFILE | Set-Content -Path (Join-Path (Split-Path -Path $PROFILE -Parent) "Microsoft.VSCode_profile.ps1")

	#--- Update all modules ---
	Write-Host 'Updating all modules...'
	Update-Module -ErrorAction SilentlyContinue

	#--- Reset default security protocol ---
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::SystemDefault
} # End of $ScriptBlock

# Run the script block in PowerShell
Write-Host 'Configuring Windows PowerShell...' -ForegroundColor 'Green'
powershell -Command $ScriptBlock

# Run the script block in PowerShell Core
Write-Host 'Configuring PowerShell Core...' -ForegroundColor 'Green'
pwsh -Command $ScriptBlock

[System.Environment]::SetEnvironmentVariable('PYTHONSTARTUP', (Join-Path $env:USERPROFILE '.pystartup'))
