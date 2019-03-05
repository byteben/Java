#Set Current Directory Script launched from
$ScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path

#Specify Java Installer
$JavaProg = $ScriptRoot+'\jre-7u15-windows-i586.exe'

#Specify Installer Arguments
$JavaArgs = '/s INSTALL_SILENT=Enable SPONSORS=0 AUTO_UPDATE=Disable REBOOT=Disable REMOVEOLDERJRES=0 REMOVEOUTOFDATEJRES=0'

#Install Java
Start-Process $JavaProg $JavaArgs -NoNewWindow -Wait -PassThru

#Wait a further 5 seconds (In testing, the file association didnt work if ran immediatly after Java installtion
Start-Sleep -s 5

Write-Host "Setting .jnlp file association to Java 7 U 15 javaws.exe"

#Associate .jnlp files with javaws.exe
$fileType = (cmd /c "assoc .jnlp")
$fileType = $fileType.Split("=")[-1]
cmd /c "ftype $fileType=""C:\Program Files (x86)\Java\jre7\bin\javaws.exe"" ""%1"""