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

	if ((Test-Path $Path) -and (Get-Item $Path | Where-Object Attributes -Match ReparsePoint)) {
		Write-Host $Path 'is already a reparse point.' | Write-Warning
		Return $false
	}
	if (Test-Path "$Path\*") {
		# $MoveResult = (Move-Item -Path $Path\* -Destination $Value -Force -PassThru -Verbose)
		$MoveResult = (robocopy $Path $Value /ZB /FFT)
		if (-not($MoveResult)) {
			Write-Host 'Something went wrong while trying to move the contents of' $Path 'to' $Value | Write-Warning
			Return $MoveResult
		}
		Remove-Item -Path $Path\* -Recurse -Force -ErrorAction Inquire
	}
	if (Test-Path $Path) {
		Remove-Item $Path -Recurse -Force
	}
	if (-not(Test-Path $Value)) {
		New-Item -Path $Value -ItemType Directory | Write-Verbose
	}
	$Result = New-Item -Path $Path -ItemType SymbolicLink -Value $Value -Force -Verbose
	if ($Result) {
		Write-Host 'Successfully created SymLink at' $Path 'pointing to' $Value | Write-Verbose
		Return $true
	} else {
		Write-Host 'The following error occured while trying to make symlink: ' $Result | Write-Warning
		Return $false
	}
}

if (-not(Get-Command New-SymbolicLink)) {
	Write-Error "The 'New-SymbolicLink' helper function was not found."
	throw
}

# if (Test-Path 'D:\') {
# 	# SymbolicLinks in AppData
# 	$SymbolicLinkNames = @('Citra')
# 	# if ($env:COMPUTERNAME | Select-String 'LAPTOP') { $SymbolicLinkNames += @('.minecraft') }
# 	foreach ($FolderName in $SymbolicLinkNames) {
# 		New-SymbolicLink -Path (Join-Path $env:APPDATA $FolderName) -Value $LinkDestination
# 	}
# }
