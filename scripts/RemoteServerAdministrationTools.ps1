dism /online /add-capability /CapabilityName:Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0 /CapabilityName:Rsat.Dns.Tools~~~~0.0.1.0 /CapabilityName:Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0

Get-WindowsCapability -Online | Where-Object { $_.Name -like "RSAT*" } | ForEach-Object { Write-Host "Installing " $_.Name; Add-WindowsCapability -Online -Name $_.Name }
