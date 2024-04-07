#--- Advanced Network Tools ---
# choco install -y advanced-ip-scanner # Possibly broken for FOSS users
# choco install -y ipscan # Possibly broken for FOSS users
# choco install -y tcpview --ignore-checksums
winget install --id=UbiquitiInc.IdentityDesktop --exact --silent --accept-package-agreements --accept-source-agreements
winget install --id=UbiquitiInc.WiFimanDesktop --exact --silent --accept-package-agreements --accept-source-agreements
# choco install -y winpcap # Dependency for wireshark
# choco install -y wireshark
winget install --id=WiresharkFoundation.Wireshark --exact --silent --accept-package-agreements --accept-source-agreements
