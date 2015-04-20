# Boxstarter script for blog post http://blog.zerosharp.com/provisioning-a-new-development-machine-with-boxstarter

# Allow reboots
$Boxstarter.RebootOk=$true
$Boxstarter.NoPassword=$false
$Boxstarter.AutoLogin=$true

# Basic setup
Update-ExecutionPolicy Unrestricted
Set-ExplorerOptions -showHidenFilesFoldersDrives -showProtectedOSFiles -showFileExtensions
Enable-RemoteDesktop
Disable-InternetExplorerESC
Disable-UAC
Set-TaskbarSmall

if (Test-PendingReboot) { Invoke-Reboot }

# Update Windows and reboot if necessary
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot) { Invoke-Reboot }

# Install Visual Studio 2013 Professional 
cinstm -y VisualStudio2013Professional -InstallArguments WebTools
if (Test-PendingReboot) { Invoke-Reboot }

cinstm -y vs2013.4
if (Test-PendingReboot) { Invoke-Reboot }

# Visual Studio SDK required for PoshTools extension
cinstm VS2013SDK
if (Test-PendingReboot) { Invoke-Reboot }

cinstm DotNet3.5 # Not automatically installed with VS 2013. Includes .NET 2.0. Uses Windows Features to install.
if (Test-PendingReboot) { Invoke-Reboot }

# VS extensions
Install-ChocolateyVsixPackage PowerShellTools http://visualstudiogallery.msdn.microsoft.com/c9eb3ba8-0c59-4944-9a62-6eee37294597/file/112013/6/PowerShellTools.vsix
Install-ChocolateyVsixPackage WebEssentials2013 http://visualstudiogallery.msdn.microsoft.com/56633663-6799-41d7-9df7-0f2a504ca361/file/105627/31/WebEssentials2013.vsix
Install-ChocolateyVsixPackage T4Toolbox http://visualstudiogallery.msdn.microsoft.com/791817a4-eb9a-4000-9c85-972cc60fd5aa/file/116854/1/T4Toolbox.12.vsix
#Install-ChocolateyVsixPackage StopOnFirstBuildError http://visualstudiogallery.msdn.microsoft.com/91aaa139-5d3c-43a7-b39f-369196a84fa5/file/44205/3/StopOnFirstBuildError.vsix

# AWS Toolkit is now an MSI available here http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi (no chocolatey package as of FEB 2014)
# Install-ChocolateyVsixPackage AwsToolkit http://visualstudiogallery.msdn.microsoft.com/175787af-a563-4306-957b-686b4ee9b497

#Other dev tools
cinstm git
cinstm fiddler4
cinstm beyondcompare
cinstm windbg
cinstm tortoisegit
cinstm nodejs.install
cinst ruby1.9

#Browsers
cinstm googlechrome
cinstm firefox

#Other essential tools
cinstm 7zip
cinstm adobereader
cinstm javaruntime
cinstm notepadplusplus
cinstm sublimetext3
cinstm hipchat
cinstm isapirewrite
cinstm webpi
cinstm resharper

#cinst Microsoft-Hyper-V-All -source windowsFeatures
cinst IIS-WebServerRole -source windowsfeatures
cinst IIS-HttpCompressionDynamic -source windowsfeatures
cinst IIS-ManagementScriptingTools -source windowsfeatures
cinst IIS-WindowsAuthentication -source windowsfeatures
cinst IIS-ISAPIFilter -source WindowsFeatures
cinst IIS-ISAPIExtensions -source WindowsFeatures

#Enable ASP.NET on win 2012/8
cinst IIS-NetFxExtensibility45 -source WindowsFeatures
cinst NetFx4Extended-ASPNET45 -source WindowsFeatures
cinst IIS-ASPNet45 -source WindowsFeatures

#rsa keys permissions
$sharepath = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
$Acl = (Get-Item $SharePath).GetAccessControl('Access')
$AccessRule= New-Object System.Security.AccessControl.FileSystemAccessRule("everyone","full","ContainerInherit,Objectinherit","none","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl $SharePath $Acl

#clone repos
$Username = Read-Host "Please enter your git username"
$Password = Read-Host "Please enter your git password"
git clone https://${Username}:${Password}@github.je-labs.com/CWA/app_publicweb.git c:\_Source\PublicWeb
git clone https://${Username}:${Password}@github.je-labs.com/CWA/ConsumerWeb.git c:\_Source\ConsumerWeb

#clean and create application
#Remove-Item c:\web\NugetServer -Recurse -Force -ErrorAction SilentlyContinue
#Mkdir c:\web\NugetServer -ErrorAction SilentlyContinue
#Copy-Item "$(Join-Path (Get-PackageRoot $MyInvocation ) NugetServer)\*" c:\web\NugetServer -Recurse -Force
Import-Module WebAdministration
Remove-WebSite -Name publicweb -ErrorAction SilentlyContinue
Remove-WebSite -Name consumerweb -ErrorAction SilentlyContinue
New-WebSite -ID 1 -Name publicweb -Port 80 -PhysicalPath c:\_Source\PublicWeb -Force
New-WebSite -ID 1 -Name consumerweb -Port 8081 -PhysicalPath c:\_Source\ConsumerWeb -Force


Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Google\Chrome\Application\chrome.exe"
Install-ChocolateyPinnedTaskBarItem "$($Boxstarter.programFiles86)\Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe"