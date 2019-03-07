#Specify Java Installer
$JavaProg = 'jre1.7.0_15.msi'
#Install Java
Start-Process msiexec.exe "/qn  /i $($JavaProg) INSTALL_SILENT=Enable SPONSORS=0 AUTO_UPDATE=Disable REBOOT=Disable REMOVEOLDERJRES=0 REMOVEOUTOFDATEJRES=0" -Wait
#Wait a further 5 seconds (In testing, the file association didnt work if ran immediatly after Java installtion)
Start-Sleep -s 5
Write-Host "Setting .jnlp file association to Java 7 U 15 javaws.exe"
#Associate .jnlp files with javaws.exe
$fileType = (cmd /c "assoc .jnlp")
$fileType = $fileType.Split("=")[-1]
cmd /c "ftype $fileType=""C:\Program Files (x86)\Java\jre7\bin\javaws.exe"" ""%1"""