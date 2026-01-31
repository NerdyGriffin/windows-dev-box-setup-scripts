function Update-EnvironmentVariables {
	try {
		$output = RefreshEnv 2>&1 | Out-String
	} catch {
		$output = $_ | Out-String
	}

	if ($output -and $output -match 'Import-Module') {
		try { Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue } catch {}
		# After importing the Chocolatey profile, try refreshenv again and display its output
		try {
			$retryOutput = RefreshEnv 2>&1 | Out-String
		} catch {
			$retryOutput = $_ | Out-String
		}
		if ($retryOutput) { Write-Host $retryOutput.Trim() }
	} else {
		if ($output) { Write-Host $output.Trim() }
	}

	return $null
}

if (([Security.Principal.WindowsPrincipal] `
			[Security.Principal.WindowsIdentity]::GetCurrent() `
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	#--- PowerShell ---
	choco upgrade -y powershell
	choco upgrade -y powershell-core
	choco upgrade -y winget
	Update-EnvironmentVariables
}

#--- Enable Powershell Script Execution
try { Set-ExecutionPolicy Bypass -Scope CurrentUser -Force } catch {} # Do nothing if blocked by Group Policy

Update-EnvironmentVariables

[ScriptBlock]$ScriptBlock = {
	function Update-EnvironmentVariables {
		try {
			$output = RefreshEnv 2>&1 | Out-String
		} catch {
			$output = $_ | Out-String
		}

		if ($output -and $output -match 'Import-Module') {
			try { Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1" -ErrorAction SilentlyContinue } catch {}
			# After importing the Chocolatey profile, try refreshenv again and display its output
			try {
				$retryOutput = RefreshEnv 2>&1 | Out-String
			} catch {
				$retryOutput = $_ | Out-String
			}
			if ($retryOutput) { Write-Host $retryOutput.Trim() }
		} else {
			if ($output) { Write-Host $output.Trim() }
		}

		return $null
	}

	#--- Enable Powershell Script Execution
	try {
		Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
	} catch {
		try {
			Set-ExecutionPolicy Bypass -Scope Process -Force
		} catch {
			# Do nothing if blocked by Group Policy
		}
	}

	Update-EnvironmentVariables

	if ((Get-CimInstance Win32_OperatingSystem).BuildNumber -lt 17763) {
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
	} else {
		[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::SystemDefault
	}

	# Set confirmation preference to prevent prompts
	$ConfirmPreference = 'None'

	if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -and (Get-Command -Name Install-PackageProvider -ErrorAction SilentlyContinue)) {
		Write-Host 'Installing NuGet Package Provider...'
		try {
			Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false -ErrorAction SilentlyContinue | Out-Null
			Import-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -ErrorAction SilentlyContinue | Out-Null
		} catch {}
	}

	#--- Powershell Module Repository
	if (Get-Command -Name Set-PSRepository -ErrorAction SilentlyContinue) {
		try {
			Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -ErrorAction SilentlyContinue
		} catch {}
	}

	if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		#--- Update all modules ---
		Write-Host 'Updating all modules...'
		Update-Module -ErrorAction SilentlyContinue
	}

	Update-EnvironmentVariables
	Start-Sleep -Seconds 1;

	#DEBUG: Delete PowerShell Profile for testing purposes
	Remove-Item -Path $PROFILE -Force -ErrorAction SilentlyContinue

	#--- Ensure PowerShell Profile Exists
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
		Update-EnvironmentVariables
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
		Update-EnvironmentVariables
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
			'if (Test-Path($ChocolateyProfile)) { Import-Module "$ChocolateyProfile" }'
		)
		if (-not(Select-String -Pattern $ChocolateyProfile[0] -Path $PROFILE)) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $ChocolateyProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $ChocolateyProfile
		}
	}

	#--- Install the CredentialManager Module
	try {
		Write-Host 'Installing CredentialManager'
		Write-Host 'Description: Provides access to credentials in the Windows Credential Manager.'
		if (-not(Get-Module -ListAvailable -Name CredentialManager)) {
			Install-Module -Name CredentialManager -Scope CurrentUser -AllowClobber -SkipPublisherCheck -Force -Verbose
		} else { Write-Host "Module 'CredentialManager' already installed" }
		Update-EnvironmentVariables
	} catch {
		Write-Host 'CredentialManager failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if CredentialManager install fails due to errors
	}

	#--- Install & Configure Oh-My-Posh
	try {
		Write-Host 'Installing Oh-My-Posh - [Powerline-style prompt for PowerShell]'
		if (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue) {
			Write-Host "Package 'Oh-My-Posh' already installed"
		} else {
			try {
				winget install JanDeDobbeleer.OhMyPosh --source winget
			} catch {
				try { Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1')) } catch {}
			}
		}
		Update-EnvironmentVariables
		try { oh-my-posh font install meslo } catch {}
		Update-EnvironmentVariables
		Write-Host 'Appending Configuration for Oh-My-Posh to PowerShell Profile...'
		$OhMyPoshProfile = @(
			'# Initialize Oh-My-Posh',
			# 'oh-my-posh --init --shell pwsh --config $env:POSH_THEMES_PATH/microverse-power.omp.json | Invoke-Expression'
			'if (Get-Command -Name oh-my-posh -ErrorAction SilentlyContinue) { oh-my-posh init $(oh-my-posh get shell) --config ''microverse-power'' | Invoke-Expression }'
			# 'oh-my-posh init $(oh-my-posh get shell) --eval --config ''microverse-power'' | Invoke-Expression'
		)
		if (-not(Select-String -Pattern $OhMyPoshProfile[0] -Path $PROFILE )) {
			Write-Output 'Attempting to add the following lines to $PROFILE :' | Write-Debug
			Write-Output $OhMyPoshProfile | Write-Debug
			Add-Content -Path $PROFILE -Value $OhMyPoshProfile
		}
		# Install additional Oh-My-Posh-related packages via Chocolatey
		# choco install -y poshgit
		# choco install -y posh-github
		# Update-EnvironmentVariables
	} catch {
		Write-Host 'Oh-My-Posh failed to install' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Oh-My-Posh install fails due to error
	}

	#--- Uninstall the Pipeworks Module
	try {
		Write-Host 'Uninstalling Pipeworks -- [CLI Tools for PowerShell]'
		Write-Host 'Description: PowerShell Pipeworks is a framework for writing Sites and Software Services in Windows PowerShell modules.'
		if (Get-Module -ListAvailable -Name Pipeworks) {
			Uninstall-Module -Name Pipeworks -Force -Verbose
		} else { Write-Host "Module 'Pipeworks' not installed. No further action required." }
		Update-EnvironmentVariables
	} catch {
		Write-Host 'Pipeworks failed to uninstall' | Write-Warning
		Write-Host ' See the log for details (' $Boxstarter.Log ').' | Write-Debug
		# Move on if Pipeworks uninstall fails due to errors
	}

	Get-Content -Path $PROFILE | Set-Content -Path (Join-Path (Split-Path -Path $PROFILE -Parent) "Microsoft.VSCode_profile.ps1")

	if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
		#--- Update all modules ---
		Write-Host 'Updating all modules...'
		Update-Module -ErrorAction SilentlyContinue
	}

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
