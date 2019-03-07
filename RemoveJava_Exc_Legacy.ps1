#Ignore Java Versions
$CurrentJavaJREToKeep = 'Java 8 Update 201'
$LegacyJavaJREToKeep = 'Java 7 Update 15'

#Get all installed Java programs
$JavaPackages = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -like "Java*" -and $_.Name -ne $CurrentJavaJREToKeep -and $_.Name -ne $LegacyJavaJREToKeep} | Select InstallLocation, Name, MsiProductCode, Version

#Get current Java programs
$CurrentJavaPackageToKeep = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -eq $CurrentJavaJREToKeep } | Select Name, MsiProductCode, Version

$LegacyJavaPackageToKeep = Get-WmiObject -Class Win32_InstalledWin32Program | Where-Object { $_.Name -eq $LegacyJavaJREToKeep } | Select Name, MsiProductCode, Version

$RegistryPathCurrentJavaToKeep = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($CurrentJavaPackageToKeep.MsiProductCode)" -Name "InstallLocation"

$RegistryPathLegacyJavaToKeep = Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$($LegacyJavaPackageToKeep.MsiProductCode)" -Name "InstallLocation"

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
		Start-Process msiexec.exe "/x $($JavaProgram.MsiProductCode) /qn /norestart" -Wait
	}
	
	#Cleanup old Java Folders
	ForEach ($Location in $Locations)
	{
		#CleanUp Java Source Folder after MSIs removed
		Write-Host "Checking if """$($Location.InstallLocation)""" needs cleaning up"
		If (Test-Path -Path $Location.InstallLocation)
		{
			Write-Host "Found left over folder:"$Location.InstallLocation
			If ($Location.InstallLocation -ne $CurrentJavaPackageToKeep.InstallLocation -or $Location.InstallLocation -ne $LegacyJavaPackageToKeep.InstallLocation)
			{
				Remove-Item -LiteralPath $Location.InstallLocation -Force -Recurse
				Write-Host "Cleaning up Directory:" $Location.InstallLocation
			}
		}
	}
		Write-Host "Directory Cleanup Complete"
}

If (!$CurrentJavaPackageToKeep){
#Set Current Directory Script launched from
$ScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Path

#Specify Java Installer
$JavaProg = $ScriptRoot+'\jre-8u201-windows-i586.exe'

#Specify Installer Arguments
$JavaArgs = '/s INSTALL_SILENT=Enable SPONSORS=0 AUTO_UPDATE=Disable REBOOT=Disable REMOVEOLDERJRES=0 REMOVEOUTOFDATEJRES=0'

#Install Java
Start-Process $JavaProg $JavaArgs -NoNewWindow -Wait -PassThru
} else {
Write-Host "$($CurrentJavaPackageToKeep.Name) already installed"
}