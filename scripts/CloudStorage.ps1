choco install -y google-drive-file-stream
# choco install -y megasync

$NextcloudCheck = choco list -l nextcloud-client | Select-String -Pattern 'nextcloud-client'
if (-not($NextcloudCheck)) {
	choco install -y nextcloud-client
}

# $NextcloudPlaceholder = Join-Path (Get-LibraryNames).Desktop 'nextcloud-placeholder'
# if (Test-Path $NextcloudPlaceholder) {
# 	Remove-Item -Path $NextcloudPlaceholder
# } else {
# 	New-Item -Path $NextcloudPlaceholder -ItemType File -Value 'This is just a marker for the script. You may delete this file'
# 	choco install -y nextcloud-client
# }
