#--- Unofficial Chocolatey Tools ---
# choco install -y choco-package-list-backup
choco install -y choco-upgrade-all-at

#--- Winget Automatic Scheduled Updates ---
$STAction = New-ScheduledTaskAction -Execute 'winget' -Argument 'upgrade --all --accept-source-agreements'
$STTrigger = New-ScheduledTaskTrigger -Daily -At 4am
$STPrin = New-ScheduledTaskPrincipal -UserId 'NT AUTHORITY\SYSTEM' -RunLevel Highest
$STSetings = New-ScheduledTaskSettingsSet

if (Get-ScheduledTask -TaskName 'WingetUpgradeAllTask' -ErrorAction SilentlyContinue) {
	Set-ScheduledTask -TaskName 'WingetUpgradeAllTask' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
} else {
	Register-ScheduledTask -TaskName 'WingetUpgradeAllTask' -Action $STAction -Principal $STPrin -Settings $STSetings -Trigger $STTrigger
}
Clear-Variable STAction, STPrin, STSetings, STTrigger
