#--- PDF ---
choco install -y adobereader
choco install -y pdfsam

#--- Office Suite ---
winget install --id=TheDocumentFoundation.LibreOffice -e --accept-source-agreements

#--- Handwritten Document & Drawing ---
choco install -y xournalplusplus

#--- E-Books ---
choco install -y calibre
choco install -y kindle

#--- Other ---
winget install --id=9MSPC6MP8FM4  -e # Microsoft Whiteboard --accept-source-agreements
