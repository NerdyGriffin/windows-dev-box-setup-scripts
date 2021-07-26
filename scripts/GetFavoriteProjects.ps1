Update-SessionEnvironment
git config --global gpg.program $(Resolve-Path (Get-Command gpg | Select-Object -Expand Source) | Select-Object -Expand Path)

function Set-CloneLocation ([String] $Path) {
	If (-not(Test-Path "$Path")) { New-Item -Path "$Path" -ItemType Directory | Write-Verbose }
	Set-Location "$Path"
}
Set-CloneLocation 'C:\GitHub'

# Feel free to customize this with your own preferred projects
Set-CloneLocation 'C:\GitHub\NerdyGriffin'
git clone https://github.com/NerdyGriffin/Boxstarter-Scripts
git clone https://github.com/NerdyGriffin/windows-dev-box-setup-scripts

Set-CloneLocation 'C:\GitHub\PowerShell'
git clone https://github.com/PowerShell/PowerShell

Set-CloneLocation 'C:\GitHub\chocolatey-community'
git clone https://github.com/chocolatey-community/chocolatey-coreteampackages.git

Set-CloneLocation 'C:\GitHub\gordon-cs'
git clone https://github.com/gordon-cs/gordon-360-api
git clone https://github.com/gordon-cs/gordon-360-ui

Set-CloneLocation 'C:\GitHub\microsoft'
git clone https://github.com/microsoft/winappdriver
git clone https://github.com/microsoft/windows-dev-box-setup-scripts
git clone https://github.com/microsoft/wsl
