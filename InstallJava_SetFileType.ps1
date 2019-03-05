$ScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path
$JavaProg = $ScriptRoot+'\jre-7u15-windows-i586.exe'
$JavaArgs = '/s INSTALL_SILENT=Enable SPONSORS=0 AUTO_UPDATE=Disable REBOOT=Disable REMOVEOLDERJRES=0 REMOVEOUTOFDATEJRES=0'
Start-Process $JavaProg $JavaArgs -NoNewWindow -Wait -PassThru
Start-Sleep -s 5
Write-Host "Setting .jnlp file association to Java 7 U 15 javaws.exe"
$fileType = (cmd /c "assoc .jnlp")
$fileType = $fileType.Split("=")[-1]
cmd /c "ftype $fileType=""C:\Program Files (x86)\Java\jre7\bin\javaws.exe"" ""%1"""