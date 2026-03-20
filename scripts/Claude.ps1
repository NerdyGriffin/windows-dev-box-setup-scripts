winget install Git.Git #TODO: Setup more robust pre-requisite checks

# Anthropic Claude desktop app
winget install --id=Anthropic.Claude --exact --silent --accept-package-agreements --accept-source-agreements

# Anthropic Claude Code CLI
irm https://claude.ai/install.ps1 | iex

# Add Claude's install directory to the user PATH if not already present
$claudeBinDir = Join-Path $env:USERPROFILE '.local\bin'
if (Test-Path $claudeBinDir) {
    $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
    if ($userPath -split ';' -notcontains $claudeBinDir) {
        Write-Host "Adding $claudeBinDir to user PATH..."
        [Environment]::SetEnvironmentVariable('PATH', "$userPath;$claudeBinDir", 'User')
        $env:PATH = "$env:PATH;$claudeBinDir"
        Write-Host "✅ Added to PATH. New terminals will pick this up automatically."
    } else {
        Write-Host "✅ $claudeBinDir is already in user PATH."
    }
} else {
    Write-Warning "$claudeBinDir not found — Claude may not have installed correctly."
}
