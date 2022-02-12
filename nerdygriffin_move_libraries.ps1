If ($Boxstarter.StopOnPackageFailure) { $Boxstarter.StopOnPackageFailure = $false }

choco upgrade -y boxstarter

Function New-SymbolicLink {
	param(
		# Specifies the path of the location of the new link. You must include the name of the new link in Path .
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = 'ParameterSetName',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = 'Specifies the path of the location of the new link. You must include the name of the new link in Path .')]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Path,

		# Specifies the path of the location that you would like the link to point to.
		[Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Specifies the path of the location that you would like the link to point to.')]
		[Alias('Target')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Value
	)

	if ("$Path" | Select-String -SimpleMatch "$Value") {
		Write-Warning "The link path cannot be the same as the link target! `n  Path: $Path `nTarget: $Value" | Write-Host
		Return $false
	} elseif ((Test-Path $Path -ErrorAction SilentlyContinue) -and (Get-Item $Path -ErrorAction SilentlyContinue | Where-Object Attributes -Match ReparsePoint)) {
		Write-Warning "'$Path' is already a reparse point." | Write-Host
		Return $false
	} elseif ("$Path" | Select-String -SimpleMatch "OneDrive") {
		Write-Warning "'$Path' is within a OneDrive directory. This link will be skipped to avoid accidentally syncing large server shares." | Write-Host
		Return $false
	} else {
		if (Test-Path "$Path\*") {
			# $MoveResult = (Move-Item -Path $Path\* -Destination $Value -Force -PassThru -Verbose)
			$MoveResult = (robocopy "$Path" "$Value" /ZB /FFT);
			if (-not($MoveResult)) {
				Write-Warning "Something went wrong while trying to move the contents of '$Path' to '$Value'" | Write-Host
				Return $MoveResult
			} else {
				Remove-Item -Path $Path\* -Recurse -Force;
			}
		}
		if (Test-Path $Path) {
			Remove-Item $Path -Recurse -Force;
		}
		if (-not(Test-Path $Value)) {
			New-Item -Path $Value -ItemType Directory | Write-Verbose
		}
		$Result = New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose;
		if ($Result) {
			Write-Host "Successfully created SymLink $Path --> $Value"
			Return $true
		} else {
			Write-Warning "The following error occured while trying to make symlink: $Result" | Write-Host
			Return $false
		}
	}
}

Function New-LibraryLinks {
	param(
		# Specifies the path of the location of the new link. You must exclude the name of the new link in Path .
		[Parameter(Mandatory = $true,
			Position = 0,
			ParameterSetName = 'ParameterSetName',
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			HelpMessage = 'Specifies the path of the location of the new link. You must exclude the name of the new link in Path .')]
		[Alias('PSPath')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Path,

		[Parameter(Mandatory = $true,
			Position = 1,
			HelpMessage = 'Specifies the name of the new link.')]
		[Alias('LinkName')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Name,

		# Specifies the path of the location that you would like the link to point to.
		[Parameter(Mandatory = $true,
			Position = 2,
			HelpMessage = 'Specifies the path of the location that you would like the link to point to.')]
		[Alias('Target')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Value
	)

	# TODO: Add a check that (Split-Path -Path "$Path" -Qualifier) is not a mapped network drive

	$DocumentsPath = ((Get-LibraryNames).Personal);
	$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}');

	@( ($env:USERPROFILE), (Split-Path -Path $Path -Parent), ($Path) ) | ForEach-Object {
		$LinkPath = (Join-Path $_ $Name);
		if (Test-Path $LinkPath) {
			Write-Host "Path already exists: $LinkPath"
		} elseif ("$_" | Select-String -SimpleMatch 'OneDrive') {
			Write-Host "Skipping path within OneDrive: $LinkPath"

		} elseif ("$_" | Select-String -SimpleMatch "$DocumentsPath") {
			Write-Host "Skipping path within Documents: $LinkPath"

		} elseif ("$_" | Select-String -SimpleMatch "$DownloadsPath") {
			Write-Host "Skipping path within Downloads: $LinkPath"

		} elseif (("$_" | Select-String -SimpleMatch 'OneDrive' -NotMatch) -and ("$_" | Select-String -SimpleMatch "$DocumentsPath" -NotMatch) -and ("$_" | Select-String -SimpleMatch "$DownloadsPath" -NotMatch)) {
			Write-Host "Creating new SymLink: '$LinkPath' --> '$Value'"
			New-Item -Path $_ -Name $Name -ItemType SymbolicLink -Value $Value -Verbose -ErrorAction SilentlyContinue | Write-Verbose
		}
	}
}

Disable-UAC

#--- Enable Powershell Script Execution
Set-ExecutionPolicy Bypass -Scope CurrentUser -Force
refreshenv

$EnableNFSScript = '\\files.nerdygriffin.net\scripts\EnableNFS.ps1'
if (Test-Path $EnableNFSScript) {
	Invoke-Expression $EnableNFSScript -ErrorAction Continue
}

if ($(Get-WindowsOptionalFeature -Online -FeatureName "ServicesForNFS-ClientOnly").State) {
	$NFSEnabled = $true
	$ServerRootPath = '\\nfs.nerdygriffin.net\mnt\user\'
	$MountServerSharesScript = (Join-Path $ServerRootPath 'scripts\MountNFSShares.bat')
} else {
	$NFSEnabled = $false
	$ServerRootPath = '\\files.nerdygriffin.net\'
	$MountServerSharesScript = (Join-Path $ServerRootPath 'scripts\MountSMBShares.ps1')
}
$ServerMediaShare = (Join-Path $ServerRootPath 'media')
$ServerDocumentsShare = (Join-Path $ServerRootPath 'personal\Documents')
$ServerDownloadsShare = (Join-Path $ServerRootPath 'personal\Downloads')

if ("$env:Username" -like '*Public*') {
	Write-Warning 'Somehow the current username is "Public"...`n  That should not be possible, so the libraries will not be moved.'
} else {
	if (Test-Path $MountServerSharesScript) {
		if ($NFSEnabled) {
			cmd.exe /c $MountServerSharesScript
		} else {
			Invoke-Expression $MountServerSharesScript -ErrorAction Continue
		}
	}

	$LibrariesToMove = @('My Music', 'My Pictures', 'My Video')

	$NewDrive = 'D:'
	if (Test-Path "$NewDrive") {
		Write-Host "Moving Library Directories to '$NewDrive' ..."

		$PSBootDrive = Get-PSDrive C
		# Only move the documents folder if the boot drive of this computer is smaller than the given threshold
		if (($PSBootDrive.Used + $PSBootDrive.Free) -lt (0.5TB)) {
			$LibrariesToMove += 'Documents'
			$LibrariesToMove += 'Downloads'
			$LibrariesToMove += 'Personal'
			$LibrariesToMove += '{374DE290-123F-4565-9164-39C4925E467B}' # This is a name for the downloads library... I have no idea why it does not use an alias
		}

		$LibrariesToMove | ForEach-Object {
			$PrevLibraryPath = ''
			$PrevLibraryPath = (Get-LibraryNames).$_
			if (($PrevLibraryPath) -and (Split-Path -Path "$PrevLibraryPath" -Qualifier | Select-String -NotMatch "$NewDrive") -and ("$PrevLibraryPath" | Select-String -SimpleMatch 'OneDrive' -NotMatch)) {
				$NewLibraryPath = (Join-Path "$NewDrive" (Split-Path -Path $PrevLibraryPath -NoQualifier)) # Convert all the existing library paths from 'C:\' to 'D:\'
				if ("$NewLibraryPath" | Select-String -SimpleMatch 'OneDrive' -NotMatch) {
					Write-Host "Moving library ""$_"" from ""$PrevLibraryPath"" to ""$NewLibraryPath""...";
					Move-LibraryDirectory -libraryName $_ -newPath $NewLibraryPath -ErrorAction Continue;
					Write-Host "Attempting to create SymLink '$PrevLibraryPath' --> '$NewLibraryPath'...";
					New-SymbolicLink -Path $PrevLibraryPath -Value $NewLibraryPath -ErrorAction Continue;
				}
			}
		}
	}

	RefreshEnv;
	Start-Sleep -Seconds 1;

	if (Test-Path $ServerMediaShare) {
		Write-Host 'Making Symbolic Links to media server shares...'
		@('My Music', 'My Pictures', 'My Video') | ForEach-Object {
			$LibraryPath = (Get-LibraryNames).$_
			$LibraryName = (Split-Path -Path $LibraryPath -Leaf -Resolve)
			$LinkName = "Server$LibraryName"
			$LinkTarget = (Join-Path "$ServerMediaShare" "$LibraryName")
			New-LibraryLinks -Path "$LibraryPath" -Name "$LinkName" -Value "$LinkTarget"
		}
	}

	if (Test-Path $ServerDocumentsShare) {
		Write-Host 'Making Symbolic Links to documents server share...'
		$DocumentsPath = ((Get-LibraryNames).Personal)
		New-LibraryLinks -Path "$DocumentsPath" -Name 'ServerDocuments' -Value "$ServerDocumentsShare"
	}

	$DownloadsShareLinkTarget = ''
	$MappedDownloadsPath = 'X:\Downloads'
	if (Test-Path $MappedDownloadsPath) {
		$DownloadsShareLinkTarget = $MappedDownloadsPath
	} elseif (Test-Path $ServerDownloadsShare) {
		$DownloadsShareLinkTarget = $ServerDownloadsShare
	}

	if ($DownloadsShareLinkTarget) {
		$DownloadsPath = ((Get-LibraryNames).'{374DE290-123F-4565-9164-39C4925E467B}')
		Write-Host 'Making Symbolic Links to downloads server share...'
		New-LibraryLinks -Path "$DownloadsPath" -Name 'ServerDownloads' -Value "$DownloadsShareLinkTarget"
	}
}

$MountServerShareMessage = "You must manually run the '$MountServerSharesScript' or script again as your non-admin user in order for the mapped drives to be visible in the File Explorer"

if (Test-Path $MountServerSharesScript) {
	Write-Host "$MountServerShareMessage"
}

Enable-UAC
Enable-MicrosoftUpdate
Install-WindowsUpdate -acceptEula

if (Test-Path $MountServerSharesScript) {
	Write-Host "$MountServerShareMessage"
}
