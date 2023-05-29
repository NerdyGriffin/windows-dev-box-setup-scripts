if (([Security.Principal.WindowsPrincipal] `
			[Security.Principal.WindowsIdentity]::GetCurrent() `
	).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
	choco install -y gnupg
	choco install -y git --package-parameters="'/GitAndUnixToolsOnPath /WindowsTerminal'"
	choco install -y gitkraken
	refreshenv
}

#--- Configure Git ---
git config --global user.name 'Christian Kunis'
git config --global user.email 'ckunis98@gmail.com'
if (Get-Command nano -ErrorAction SilentlyContinue) {
	git config --global core.editor nano
} else {
	git config --global core.editor code
}
git config --global color.status auto
git config --global color.diff auto
git config --global color.branch auto
git config --global color.interactive auto
git config --global color.ui true
git config --global color.pager true
git config --global color.showbranch auto
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.ft fetch
git config --global alias.ps push
git config --global alias.ph push
git config --global alias.pl pull
git config --global gpg.program $(Resolve-Path (Get-Command gpg | Select-Object -Expand Source) | Select-Object -Expand Path)

# Make a folder for my GitHub repos and make SymbolicLinks to it
$UserGitHubPath = (Join-Path $env:USERPROFILE 'GitHub')
if (-not(Test-Path $UserGitHubPath)) { New-Item -Path $UserGitHubPath -ItemType Directory }
if (-not(Test-Path 'C:\GitHub')) { New-Item -Path 'C:\GitHub' -ItemType SymbolicLink -Value $UserGitHubPath }
# if ((Test-Path 'D:\') -and -not(Test-Path 'D:\GitHub')) { New-Item -Path 'D:\GitHub' -ItemType SymbolicLink -Value 'C:\GitHub' }
