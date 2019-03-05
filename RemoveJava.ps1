#Ignore latest Java Version
$CurrentJavaJRE = 'Java 8 Update 201'

#Get all installed Java programs
$JavaPackages = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -like "Java*" -and $_.Name -ne $CurrentJavaJRE } | Select InstallLocation, Name, MsiProductCode, Version

#Get current Java program
$CurrentJavaPackage = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -eq 'Java 8 Update 201' } | Select Name, MsiProductCode, Version
$RegistryPathCurrentJava = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($CurrentJavaPackage.MsiProductCode)" -Name "InstallLocation"

#Initialise array for Install Locations for each Java program
$Locations = @()

#Remove Java Programs
ForEach ($JavaProgram in $JavaPackages)
{
	#Get InstallLocation from Registry
	$RegistryPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($JavaProgram.MsiProductCode)" -Name "InstallLocation"
	
	#Create New Object for Java Location
	$Path = New-Object PSObject
	$Path | Add-Member -Type NoteProperty -Name 'InstallLocation' -value $RegistryPath
	$Locations += $Path
	
	#Uninstall Java
	Write-Host "Uninstalling:" $($JavaProgram.Name)
	Start-Process msiexec.exe "/x $($JavaProgram.MsiProductCode) /qn" -Wait
	MD $RegistryPath.InstallLocation
}

#Cleanup old Java Folders
ForEach ($Location in $Locations)
{
	#CleanUp Java Source Folder after MSIs removed
	Write-Host "Checking if """$Location.InstallLocation""" needs cleaning up"
	If ([System.IO.File]::Exists($($Location.InstallLocation)) -and $Location.InstallLocation -ne $($CurrentJavaPackage.InstallLocation))
	{
		Remove-Item -LiteralPath $($JavaProgram.InstallLocation) -Force -Recurse
		Write-Host "Cleaning up Directory:" $($Location.InstallLocation)
	}
	else
	{
		Write-Host "Directory Cleanup not required for:"$($Location.InstallLocation)
	}
}