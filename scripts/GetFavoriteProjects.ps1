Update-SessionEnvironment
git config --global gpg.program $(Resolve-Path (Get-Command gpg | Select-Object -Expand Source) | Select-Object -Expand Path)

function Set-CloneLocation ([String] $Path) {
	If (-not(Test-Path "$Path")) { New-Item -Path "$Path" -ItemType Directory | Write-Verbose }
	Set-Location "$Path"
}
Set-CloneLocation 'C:\GitHub'

# Feel free to customize this with your own preferred projects

Set-CloneLocation 'C:\GitHub\chocolatey-community'
git clone git@github.com:chocolatey-community/chocolatey-coreteampackages.git

Set-CloneLocation 'C:\GitHub\gordon-cs'
git clone git@github.com:gordon-cs/gordon-360-api
git clone git@github.com:gordon-cs/gordon-360-ui

Set-CloneLocation 'C:\GitHub\microsoft'
git clone git@github.com:microsoft/winappdriver
git clone git@github.com:microsoft/windows-dev-box-setup-scripts
git clone git@github.com:microsoft/wsl

Set-CloneLocation 'C:\GitHub\NerdyGriffin'
git clone git@github.com:NerdyGriffin/Cura
git clone git@github.com:NerdyGriffin/DSC_v2
git clone git@github.com:NerdyGriffin/USMT.git
git clone git@github.com:NerdyGriffin/windows-dev-box-setup-scripts

Set-CloneLocation 'C:\GitHub\PowerShell'
git clone git@github.com:PowerShell/PowerShell

Set-CloneLocation 'C:\GitHub\Ultimaker'
git clone git@github.com:Ultimaker/Cura.git

Set-CloneLocation 'C:\GitHub\WCEngineer'
git clone git@github.com:WCEngineer/USMT.git
git clone git@github.com:WCEngineer/wh-windows-setup-scripts.git