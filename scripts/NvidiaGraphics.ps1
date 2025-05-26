$PrevRebootState = $Boxstarter.RebootOk -or $false
$Boxstarter.RebootOk = $false

#--- Nvidia Graphics ---
choco install -y nvidia-app
# choco install -y nvidia-profile-inspector

$Boxstarter.RebootOk = $PrevRebootState
