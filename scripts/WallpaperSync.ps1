#--- Setting up custom file sync script if possible ---
choco install -y freefilesync
RefreshEnv;
Start-Sleep -Seconds 1;

$SMBProgramFilesPath = '\\files.nerdygriffin.net\programfiles'
$FreeFileSyncExe = (Join-Path $env:ProgramFiles '\FreeFileSync\FreeFileSync.exe')
# $RealTimeSyncExe = (Join-Path $env:ProgramFiles '\FreeFileSync\RealTimeSync.exe')

try {
	If (Test-Path $SMBProgramFilesPath) {
		$WallpaperFFSReal = 'MirrorCuratedSlideshowWallpaper.ffs_real'
		$WallpaperFFSBatch = 'MirrorCuratedSlideshowWallpaper.ffs_batch'

		$WallpaperFFSRealLocalPath = (Join-Path $env:ProgramData $WallpaperFFSReal)
		$WallpaperFFSBatchLocalPath = (Join-Path $env:ProgramData $WallpaperFFSBatch)
		$WallpaperFFSRealRemotePath = (Join-Path $SMBProgramFilesPath $WallpaperFFSReal)
		$WallpaperFFSBatchRemotePath = (Join-Path $SMBProgramFilesPath $WallpaperFFSBatch)

		# $WallpaperCommand = """$RealTimeSyncExe"" ""$WallpaperFFSRealLocalPath"""

		If ((Test-Path $WallpaperFFSRealRemotePath) -and (Test-Path $WallpaperFFSBatchRemotePath)) {
			Copy-Item -Path $WallpaperFFSRealRemotePath -Destination $WallpaperFFSRealLocalPath -Force
			Copy-Item -Path $WallpaperFFSBatchRemotePath -Destination $WallpaperFFSBatchLocalPath -Force

			$STAction = New-ScheduledTaskAction -Execute "$FreeFileSyncExe" -Argument "$WallpaperFFSBatchLocalPath"
			$STTrigger = @(
				$(New-ScheduledTaskTrigger -Daily -At 12am),
				$(New-ScheduledTaskTrigger -Daily -At 6am),
				$(New-ScheduledTaskTrigger -Daily -At 12pm),
				$(New-ScheduledTaskTrigger -Daily -At 6pm)
			)
			$STSetings = New-ScheduledTaskSettingsSet -DisallowStartOnRemoteAppSession -ExecutionTimeLimit (New-TimeSpan -Hours 1) -IdleDuration (New-TimeSpan -Minutes 1) -IdleWaitTimeout (New-TimeSpan -Hours 4) -MultipleInstances IgnoreNew -Priority 5 -RunOnlyIfNetworkAvailable

			if (Get-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -ErrorAction SilentlyContinue) {
				Set-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -Action $STAction -Settings $STSetings -Trigger $STTrigger
			} else {
				Register-ScheduledTask -TaskName 'FreeFileSyncWallpaper' -Action $STAction -Settings $STSetings -Trigger $STTrigger
			}
			# Export-ScheduledTask -TaskName 'FreeFileSyncWallpaper' #! DEBUG: This line is for debug testing

			if (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncWallpaper -ErrorAction SilentlyContinue) {
				Write-Host "Removing deprecated registry entry for the 'RealTimeSyncWallpaper' script"
				Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name RealTimeSyncWallpaper
			}
		}
	}
} catch {
	Write-Warning "An error occurred while attempting to setup wallpaper folder sync. This script will be skipped."
} finally {

}

# TODO: Look into using ShadowCopy (Chris Titus) or TeraCopy
