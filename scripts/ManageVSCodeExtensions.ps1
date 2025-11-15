<#
.SYNOPSIS
	Disables VS Code extensions that should only be enabled per-workspace.

.DESCRIPTION
	This script disables language-specific and tool-specific VS Code extensions globally.
	These extensions can then be re-enabled on a per-workspace basis as needed.
	This helps keep VS Code lightweight and reduces clutter in the Extensions view.

.NOTES
	Author: NerdyGriffin
	Date: November 11, 2025
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

Write-Host "Starting to disable workspace-specific extensions..." -ForegroundColor Cyan
Write-Host "Total extensions to disable: $($extensionsToDisable.Count)" -ForegroundColor Yellow
Write-Host ""

$successCount = 0
$failCount = 0
$notInstalledCount = 0

foreach ($extension in $extensionsToDisable) {
	Write-Host "Processing: $extension" -ForegroundColor Gray

	# Check if extension is installed
	$installed = code --list-extensions | Where-Object { $_ -eq $extension }

	if ($installed) {
		try {
			# Disable the extension
			$result = code --disable-extension $extension --reuse-window 2>&1

			if ($LASTEXITCODE -eq 0) {
				Write-Host "  ✓ Successfully disabled: $extension" -ForegroundColor Green
				$successCount++
			} else {
				Write-Host "  ✗ Failed to disable: $extension" -ForegroundColor Red
				Write-Host "    Error: $result" -ForegroundColor Red
				$failCount++
			}
		}
		catch {
			Write-Host "  ✗ Error disabling: $extension - $_" -ForegroundColor Red
			$failCount++
		}
	} else {
		Write-Host "  - Not installed: $extension" -ForegroundColor DarkGray
		$notInstalledCount++
	}
}

foreach ($extension in $extensionsToEnable) {
	Write-Host "Processing enable: $extension" -ForegroundColor Gray

	# Check if extension is installed
	$installed = code --list-extensions | Where-Object { $_ -eq $extension }

	if ($installed) {
		try {
			# Enable the extension
			$result = code --enable-extension $extension --reuse-window 2>&1

			if ($LASTEXITCODE -eq 0) {
				Write-Host "  ✓ Successfully enabled: $extension" -ForegroundColor Green
			} else {
				Write-Host "  ✗ Failed to enable: $extension" -ForegroundColor Red
				Write-Host "    Error: $result" -ForegroundColor Red
			}
		}
		catch {
			Write-Host "  ✗ Error enabling: $extension - $_" -ForegroundColor Red
		}
	} else {
		Write-Host "  - Not installed: $extension" -ForegroundColor DarkGray
	}
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  Successfully disabled: $successCount" -ForegroundColor Green
Write-Host "  Failed to disable: $failCount" -ForegroundColor Red
Write-Host "  Not installed: $notInstalledCount" -ForegroundColor DarkGray
Write-Host "  Total processed: $($extensionsToDisable.Count)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Note: You may need to reload VS Code for all changes to take effect." -ForegroundColor Yellow
Write-Host "To enable an extension in a specific workspace:" -ForegroundColor Cyan
Write-Host "  1. Open the workspace in VS Code" -ForegroundColor Cyan
Write-Host "  2. Go to Extensions (Ctrl+Shift+X)" -ForegroundColor Cyan
Write-Host "  3. Find the disabled extension" -ForegroundColor Cyan
Write-Host "  4. Click the gear icon and select 'Enable (Workspace)'" -ForegroundColor Cyan
