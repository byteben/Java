#Ignore latest Java Version
$CurrentJavaJRE = 'Java 8 Update 201'
$LogDir = 'C:\Logs'

#Get all installed Java programs
$JavaPackages = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -like "Java*" -and $_.Name -ne $CurrentJavaJRE } | Select InstallLocation, Name, MsiProductCode, Version

#Get current Java program
$CurrentJavaPackage = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -eq 'Java 8 Update 201' } | Select Name, MsiProductCode, Version
$RegistryPathCurrentJava = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($CurrentJavaPackage.MsiProductCode)" -Name "InstallLocation"

Write-Host "RegistryPathCurrentJava:" $RegistryPathCurrentJava.InstallLocation

#Remove Java Programs
ForEach ($JavaProgram in $JavaPackages)
{
	#Get InstallLocation from Registry
	$RegistryPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($JavaProgram.MsiProductCode)" -Name "InstallLocation"
	
	#Uninstall Java
	Start-Process msiexec.exe "/x $($JavaProgram.MsiProductCode) /qn /l*vs $($LogDir)java_uninstall.log" -Wait
}

#Cleanup old Java Folders
ForEach ($JavaProgram in $JavaPackages)
{
	
	#CleanUp Java Source Folder after MSIs removed
	If ([System.IO.File]::Exists($($JavaProgram.InstallSource)) -and $($JavaProgram.InstallLocation) -ne $($CurrentJavaPackage.InstallLocation))
	{
		Remove-Item -LiteralPath $($JavaProgram.InstallSource) -Force -Recurse
	}
}