Write-Host 'Configuring Chocolatey to use local Nexus repository'
choco source disable --name='chocolatey'
choco source add --name='nexus' --source='http://nexus.nerdygriffin.net:8081/repository/chocolatey-group/'
choco config set --name="commandExecutionTimeoutSeconds" --value="14400"
