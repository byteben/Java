#Ignore latest Java Version
$CurrentJavaJRE = 'Java 8 Update 201'

#Get all installed Java programs
$JavaPackages = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -like "Java*" -and $_.Name -ne $CurrentJavaJRE } | Select Name, MsiProductCode, Version

#Initialise array to store unique uninstall strings
ForEach ($JavaProgram in $JavaPackages)
{
	Start-Process msiexec.exe "/x $($JavaProgram.MsiProductCode) /qn" -wait
}