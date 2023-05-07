Write-Host 'Configuring Chocolatey to use local Nexus repository'
choco source remove -n=chocolatey
choco source add -n=nexus -s=http://nexus.nerdygriffin.net:8081/repository/chocolatey-group/
choco config set --name="commandExecutionTimeoutSeconds" --value="14400"
