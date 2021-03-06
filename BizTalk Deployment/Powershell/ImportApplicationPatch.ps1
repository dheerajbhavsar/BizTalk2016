
param 
( 
    [Parameter(Mandatory=$true)] 
    [string]$server = "SomeServer", 
    [Parameter(Mandatory=$true)] 
    [string]$database = "SomeDatabase",
    [Parameter(Mandatory=$true)] 
    [string]$application = "SomeApp",
    [Parameter(Mandatory=$true)] 
    [string]$msi = "SomeApp.msi",
    [Parameter(Mandatory=$false)] 
    [string]$env
)

Write-Host "Execute import patch with:"
Write-Host "   server = $server"
Write-Host "   database = $database"
Write-Host "   application = $application"
Write-Host "   msi = $msi"
Write-Host "   env = $env"
$startDate = Get-Date
Write-Host "On" $startDate

# validate the msi file
if (!(Test-Path -Path "$msi")) {
    Write-Host "$msi could not be located!"
    exit
}

$currentLoc = Get-Location
$programFiles = ${env:programfiles(x86)}
if ($ProgramFiles -eq $null) { $programFiles = ${env:programfiles} }

# do some cleanup first
#if (Get-PSDrive -Name BizTalk -ErrorAction:SilentlyContinue) { Remove-PSDrive -Name BizTalk }
#if (get-pssnapin | where-object { $_.Name -eq 'BizTalkFactory.Powershell.Extensions' }) { 
#    Remove-PSSnapIn BizTalkFactory.PowerShell.Extensions }

# GroupRegistrationInfo
if (!(Get-Alias -Name 'GroupRegistrationInfo' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GroupRegistrationInfo' -Value "$BizTalkPSFolder\GroupRegistrationInfo.ps1"
}
# BTSTask
if (!(Get-Alias -Name 'BTSTask' -ErrorAction:SilentlyContinue)) {
    $exefile = (Get-ChildItem "$programFiles\Microsoft BizTalk Server 2016\btstask.exe" -ErrorAction:SilentlyContinue)
    if ($exefile.Exists) {
        Set-Alias -Name 'BTSTask' -Value "$programFiles\Microsoft BizTalk Server 2016\btstask.exe"
    } else {
	    throw "$programFiles\Microsoft BizTalk Server 2016\btstask.exe not found"
    }
}

if ($server -eq "SomeServer") {
# get the group registration info
# the variables $MgmtDBName and $MgmtDBServer
GroupRegistrationInfo
if (!($MgmtDBServer)) {
    Write-Host "No BizTalk group info available" 
    exit
}
$server = $MgmtDBServer
$database = $MgmtDBName
}

Write-Host "Clear the deployment cache ..."
Remove-Item "$env:APPDATA\Microsoft\BizTalk Server\Deployment\*" -recurse -force -ErrorAction:SilentlyContinue

Write-Host "Importing patch $msi into $application ..."

# Set the location to the path of the msi
$file = (Get-ChildItem "$msi" -ErrorAction:Stop)
Set-Location $file.Directory.FullName

# Import will fail if some dll references a dll from another application...
if ($env) {
BTSTask ImportApp -Package:$file.Name -ApplicationName:"$application" -Overwrite -Environment:$env
} else {
BTSTask ImportApp -Package:$file.Name -ApplicationName:"$application" -Overwrite 
}
if ($LastExitCode  -ne 0) { 
    Set-Location $currentLoc
    throw "Error importing $msi" 
}
$endDate = Get-Date
Write-Host "Import finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""
Set-Location $currentLoc
