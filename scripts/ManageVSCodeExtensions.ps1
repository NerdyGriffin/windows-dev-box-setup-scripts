<#
.SYNOPSIS
	Bulk-manages VS Code extensions: disables workspace-specific extensions globally and enables selected extensions as needed.

.DESCRIPTION
	ManageVSCodeExtensions.ps1 disables language-specific and tool-specific VS Code extensions globally, and enables selected extensions for your environment.
	Use this script to keep VS Code lightweight, reduce clutter, and quickly toggle extension states for different workflows.

.NOTES
	Author: NerdyGriffin
	Date: November 11, 2025
	Renamed: November 15, 2025
#>

# Extensions to disable globally (enable per-workspace as needed)
$extensionsToDisable = @(
	# MATLAB Extensions
	'affenwiesel.matlab-formatter',
	'apommel.matlab-interactive-terminal',
	'bat67.matlab-extension-pack',
	'bramvanbilsen.matlab-code-run',
	'gimly81.matlab',
	'slaier.matlab-complete',

	# Octave Extensions
	'leafvmaple.octave',
	'paulosilva.vsc-octave-debugger',
	'toasty-technologies.octave',
	'tusindfryd.octave-formatter',

	# Python/Jupyter Extensions
	'ms-python.debugpy',
	'ms-python.python',
	'ms-python.vscode-pylance',
	'ms-python.vscode-python-envs',
	'ms-toolsai.jupyter',
	'ms-toolsai.jupyter-keymap',
	'ms-toolsai.jupyter-renderers',
	'ms-toolsai.vscode-jupyter-cell-tags',
	'ms-toolsai.vscode-jupyter-slideshow',

	# C/C++ Extensions
	'jeff-hykin.better-cpp-syntax',
	'kriegalex.vscode-cudacpp',
	'ms-vscode.cpptools',
	'ms-vscode.cpptools-extension-pack',
	'ms-vscode.cpptools-themes',

	# C#/.NET Extensions
	'ms-dotnettools.csharp',
	'ms-dotnettools.vscode-dotnet-runtime',

	# Java Extensions
	'redhat.java',
	'vscjava.vscode-maven',
	'visualstudioexptteam.intellicode-api-usage-examples',

	# Go Extensions
	'golang.go',

	# React/JavaScript Extensions
	'dsznajder.es7-react-js-snippets',
	'msjsdiag.vscode-react-native',

	# Arduino/Embedded Extensions
	'jfpoilpret.fastarduino',
	'ms-vscode.vscode-serial-monitor',
	'paulober.pico-w-go',
	'raspberry-pi.raspberry-pi-pico',
	'ronaldosena.arduino-snippets',

	# MCU/Embedded Debug Extensions
	'marus25.cortex-debug',
	'mcu-debug.debug-tracker-vscode',
	'mcu-debug.memory-view',
	'mcu-debug.peripheral-viewer',
	'mcu-debug.rtos-views',

	# Assembly Extensions
	'kdarkhan.mips',

	# G-Code Extensions
	'appliedengdesign.vscode-gcode-syntax',

	# AutoHotkey Extensions
	'mark-wiemer.vscode-autohotkey-plus-plus',

	# M3U Extensions
	'af4jm.vscode-m3u',

	# Docker/Container Extensions
	'docker.docker',
	'ms-azuretools.vscode-containers',
	'ms-azuretools.vscode-docker',
	'ms-vscode-remote.remote-containers',

	# Kubernetes Extensions
	'ms-kubernetes-tools.vscode-kubernetes-tools',

	# SQL/Database Extensions
	'ms-mssql.data-workspace-vscode',
	'ms-mssql.mssql',
	'ms-mssql.sql-bindings-vscode',
	'ms-mssql.sql-database-projects-vscode',
	'mtxr.sqltools',

	# CMake/Make Extensions
	'ms-vscode.cmake-tools',
	'ms-vscode.makefile-tools',
	'twxs.cmake',

	# LaTeX Extensions
	'james-yu.latex-workshop',

	# Chocolatey Extensions
	'gep13.chocolatey-vscode',

	# 3D Printing Extensions
	'whi-tw.klipper-config-syntax',

	# Firefox Debug Extensions
	'firefox-devtools.vscode-firefox-debug',

	# Testing Extensions
	'hbenl.vscode-test-explorer',
	'ms-vscode.test-adapter-converter',

	# Live Share Extensions
	'ms-vsliveshare.vsliveshare',

	# Registry File Extensions
	'ionutvmi.reg',

	# XML/YAML Extensions (project-specific formats)
	'redhat.vscode-commons',
	'redhat.vscode-xml',
	'redhat.vscode-yaml',

	# ESLint (JavaScript/TypeScript linting - project specific)
	'dbaeumer.vscode-eslint',
	'rvest.vs-code-prettier-eslint',

	# Stylelint (CSS linting - project specific)
	'stylelint.vscode-stylelint',

	# Doxygen (C/C++ documentation)
	'cschlosser.doxdocgen',

	# PowerShell Extensions
	'ms-vscode.powershell',

	# Ansible Extensions
	'redhat.ansible'
)

$extensionsToEnable = @(
	'jamief.vscode-ssh-config-enhanced',
	'ms-vscode.remote-explorer',
	'ms-vscode-remote.remote-ssh-edit',
	'ms-vscode-remote.vscode-remote-extensionpack'
)

# Cache installed extensions to avoid calling `code --list-extensions` repeatedly
$installedExtensionsOutput = code --list-extensions 2>&1
$installedExtensionsExitCode = $LASTEXITCODE
if ($installedExtensionsExitCode -ne 0) {
    Write-Host "ERROR: Failed to run 'code --list-extensions'. Is VS Code installed and the 'code' command available in your PATH?" -ForegroundColor Red
    Write-Host "Details: $installedExtensionsOutput" -ForegroundColor Red
    exit 1
}
$installedExtensions = $installedExtensionsOutput -as [string[]]

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ManageVSCodeExtensions.ps1" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Preparing to manage VS Code extensions..." -ForegroundColor Cyan
Write-Host "  - To disable: $($extensionsToDisable.Count)" -ForegroundColor Yellow
Write-Host "  - To enable:  $($extensionsToEnable.Count)" -ForegroundColor Yellow
Write-Host ""

# Counters for disabling
$disableSuccessCount = 0
$disableFailCount = 0
$disableNotInstalledCount = 0

foreach ($extension in $extensionsToDisable) {
	Write-Host "Disabling: $extension" -ForegroundColor Gray

	# Check if extension is installed
	$installed = $installedExtensions -contains $extension

	if ($installed) {
		try {
			# Disable the extension
			$result = code --disable-extension $extension --reuse-window 2>&1

			if ($LASTEXITCODE -eq 0) {
				Write-Host "  OK: Successfully disabled: $extension" -ForegroundColor Green
				$disableSuccessCount++
			} else {
				Write-Host "  FAIL: Failed to disable: $extension" -ForegroundColor Red
				Write-Host "    Error: $result" -ForegroundColor Red
				$disableFailCount++
			}
		} catch {
			Write-Host "  FAIL: Error disabling: $extension - $_" -ForegroundColor Red
			$disableFailCount++
		}
	} else {
		Write-Host "  - Not installed: $extension" -ForegroundColor DarkGray
		$disableNotInstalledCount++
	}
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enabling selected extensions globally..." -ForegroundColor Cyan
Write-Host "Total to enable: $($extensionsToEnable.Count)" -ForegroundColor Yellow
Write-Host ""

# Counters for enabling
$enableSuccessCount = 0
$enableFailCount = 0
$enableNotInstalledCount = 0

foreach ($extension in $extensionsToEnable) {
	Write-Host "Enabling: $extension" -ForegroundColor Gray

	# Check if extension is installed
	$installed = $installedExtensions -contains $extension

	if ($installed) {
		try {
			# Enable the extension
			$result = code --enable-extension $extension --reuse-window 2>&1

			if ($LASTEXITCODE -eq 0) {
				Write-Host "  OK: Successfully enabled: $extension" -ForegroundColor Green
				$enableSuccessCount++
			} else {
				Write-Host "  FAIL: Failed to enable: $extension" -ForegroundColor Red
				Write-Host "    Error: $result" -ForegroundColor Red
				$enableFailCount++
			}
		} catch {
			Write-Host "  FAIL: Error enabling: $extension - $_" -ForegroundColor Red
			$enableFailCount++
		}
	} else {
		Write-Host "  - Not installed: $extension" -ForegroundColor DarkGray
		$enableNotInstalledCount++
	}
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Successfully disabled: $disableSuccessCount" -ForegroundColor Green
Write-Host "  Failed to disable: $disableFailCount" -ForegroundColor Red
Write-Host "  Not installed (disable list): $disableNotInstalledCount" -ForegroundColor DarkGray
Write-Host "  Successfully enabled: $enableSuccessCount" -ForegroundColor Green
Write-Host "  Failed to enable: $enableFailCount" -ForegroundColor Red
Write-Host "  Not installed (enable list): $enableNotInstalledCount" -ForegroundColor DarkGray
Write-Host "  Total disabled: $($extensionsToDisable.Count)" -ForegroundColor Yellow
Write-Host "  Total enabled: $($extensionsToEnable.Count)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: You may need to reload VS Code for all changes to take effect." -ForegroundColor Yellow
Write-Host "To enable an extension in a specific workspace:" -ForegroundColor Cyan
Write-Host "  1. Open the workspace in VS Code" -ForegroundColor Cyan
Write-Host "  2. Go to Extensions (Ctrl+Shift+X)" -ForegroundColor Cyan
Write-Host "  3. Find the disabled extension" -ForegroundColor Cyan
Write-Host "  4. Click the gear icon and select 'Enable (Workspace)'" -ForegroundColor Cyan
