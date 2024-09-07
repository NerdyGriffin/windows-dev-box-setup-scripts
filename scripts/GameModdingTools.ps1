#--- Mods & Cheats
# choco install -y cheatengine # Package no longer found
choco install -y vortex
winget install --id=WeMod.WeMod --exact --silent --accept-package-agreements --accept-source-agreements

# Install python
choco install -y python

# Refresh path
refreshenv

# Update pip
python -m pip install --upgrade pip

# powershell -c "irm https://github.com/NiceneNerd/ukmm/releases/download/v0.15.0/ukmm-installer.ps1 | iex"
powershell -c "irm https://github.com/NiceneNerd/ukmm/releases/download/latest/ukmm-installer.ps1 | iex"
