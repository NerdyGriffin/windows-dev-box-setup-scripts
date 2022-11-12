$ShortcutPath = Join-Path $env:HOMEPATH "Desktop\windows-dev-box-setup-scripts.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WscriptObj.CreateShortcut($ShortcutPath)
$shortcut.TargetPath = "https://github.com/NerdyGriffin/windows-dev-box-setup-scripts"
$shortcut.Save()
