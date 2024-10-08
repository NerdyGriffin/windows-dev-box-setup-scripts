Write-Host 'Configuring Chocolatey to use local Nexus repository'
# choco source disable --name='chocolatey'
choco source add --name='nexus' --source='https://nexus.nerdygriffin.net/repository/chocolatey-group/' --priority=1
choco config set --name="commandExecutionTimeoutSeconds" --value="14400"
