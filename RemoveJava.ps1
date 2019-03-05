#Ignore latest Java Version
$CurrentJavaJRE = 'Java 8 Update 201'

#Get all installed Java programs
$JavaPackages = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -like "Java*" -and $_.Name -ne $CurrentJavaJRE } | Select InstallLocation, Name, MsiProductCode, Version

#Get current Java program
$CurrentJavaPackage = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -eq 'Java 8 Update 201' } | Select Name, MsiProductCode, Version

$RegistryPathCurrentJava = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($CurrentJavaPackage.MsiProductCode)" -Name "InstallLocation"

#Initialise array for Install Locations for each Java program
$Locations = @()

If (!$JavaPackages)
{
	Write-Host "No qualifying Java Programs to Uninstall"
}
else
{
	#Remove Java Programs
	ForEach ($JavaProgram in $JavaPackages)
	{
		#Get InstallLocation from Registry
		$RegistryPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($JavaProgram.MsiProductCode)" -Name "InstallLocation"
		
		#Create New Object for Java Location
		$Path = New-Object PSObject
		$Path | Add-Member -Type NoteProperty -Name 'InstallLocation' -value $RegistryPath.InstallLocation
		$Locations += $Path
		
		#Uninstall Java
		Write-Host "Uninstalling:" $($JavaProgram.Name)
		Start-Process msiexec.exe "/x $($JavaProgram.MsiProductCode) /qn" -Wait
	}
	
	#Cleanup old Java Folders
	ForEach ($Location in $Locations)
	{
		#CleanUp Java Source Folder after MSIs removed
		Write-Host "Checking if """$($Location.InstallLocation)""" needs cleaning up"
		If (Test-Path -Path $Location.InstallLocation)
		{
			Write-Host "Found left over folder:"$Location.InstallLocation
			If ($Location.InstallLocation -ne $CurrentJavaPackage.InstallLocation)
			{
				Remove-Item -LiteralPath $Location.InstallLocation -Force -Recurse
				Write-Host "Cleaning up Directory:" $Location.InstallLocation
			}
		}
	}
		Write-Host "Directory Cleanup Complete"
}