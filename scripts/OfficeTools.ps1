#--- PDF ---
choco install -y adobereader
choco install -y pdfsam

#--- Office Suite ---
winget install --id=ONLYOFFICE.DesktopEditors --exact --silent --accept-package-agreements --accept-source-agreements

#--- Handwritten Document & Drawing ---
choco install -y xournalplusplus
