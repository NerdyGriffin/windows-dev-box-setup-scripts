#--- Parse Boxstarter log for failed package installs ---
$FailuresLog = (Join-Path ((Get-LibraryNames).Desktop) '\boxstarter-failures.log')
If (-not(Test-Path $FailuresLog)) {
	New-Item -Path $FailuresLog -ItemType File | Out-Null
}
Get-Content -Path $Boxstarter.Log | Select-String -Pattern '^Failures$' -Context 0, 2 | ForEach-Object {
	$FirstLine = $_.Context.PostContext[0]
	$SplitString = $FirstLine.split()
	$PackageName = $SplitString[2]
	if (-not(Select-String -Pattern $PackageName -Path $FailuresLog )) {
		Add-Content -Path $FailuresLog -Value $_.Context.PostContext
	}
}
