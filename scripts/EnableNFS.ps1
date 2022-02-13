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
