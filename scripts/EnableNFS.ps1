#Requires -RunAsAdministrator

# Enable NFS in windows if necessary
Enable-WindowsOptionalFeature -Online -FeatureName "ServicesForNFS-ClientOnly" -All
Enable-WindowsOptionalFeature -Online -FeatureName "ClientForNFS-Infrastructure" -All
Enable-WindowsOptionalFeature -Online -FeatureName "NFS-Administration" -All
nfsadmin client stop
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousUID" -Type DWord -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\ClientForNFS\CurrentVersion\Default" -Name "AnonymousGID" -Type DWord -Value 0
nfsadmin client start
nfsadmin client localhost config fileaccess=755 SecFlavors=+sys -krb5 -krb5i
Write-Host "NFS is now setup for user based NFS mounts"

# $SMBScriptsPath = '\\files.nerdygriffin.net\scripts'
# $NFSScriptsPath = '\\nfs.nerdygriffin.net\mnt\user\scripts'
# If ((Test-Path $SMBScriptsPath) -and (Test-Path $NFSScriptsPath)) {

# 	$MountNFSBatch = 'MountNFSShares.bat'

# 	# $MountNFSBatchLocalPath = (Join-Path $env:ProgramData $MountNFSBatch)
# 	$MountNFSBatchRemotePath = (Join-Path $NFSScriptsPath $MountNFSBatch)

# 	If (Test-Path $MountNFSBatchRemotePath) {
# 		# Copy-Item -Path $MountNFSBatchRemotePath -Destination $MountNFSBatchLocalPath -Force

# 		$STAction = New-ScheduledTaskAction -Execute "$MountNFSBatchRemotePath"
# 		$STTrigger = New-ScheduledTaskTrigger -AtLogOn
# 		$STPrin = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
# 		$STSetings = New-ScheduledTaskSettingsSet

# 		If (Get-ScheduledTask -TaskName 'MountNFSShares' -ErrorAction SilentlyContinue) {
# 			Set-ScheduledTask -TaskName 'MountNFSShares' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
# 		} else {
# 			Register-ScheduledTask -TaskName 'MountNFSShares' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
# 		}
# 		Clear-Variable STAction, STPrin, STSetings, STTrigger
# 	}
# }
