$PrevRebootState = $Boxstarter.RebootOk -or $false
$Boxstarter.RebootOk = $false

#--- Nvidia Graphics ---
choco install -y geforce-experience
choco install -y nvidia-profile-inspector

$Boxstarter.RebootOk = $PrevRebootState
