
param 
( 
    [Parameter(Mandatory=$true)] 
    [string]$server, 
    [Parameter(Mandatory=$true)] 
    [string]$database,
    [Parameter(Mandatory=$true)] 
    [string]$application,
    [Parameter(Mandatory=$true)] 
    [string]$env,
    [Parameter(Mandatory=$false)] 
    [string]$version,
    [Parameter(Mandatory=$false)] 
	[string]$logfile
)

Get-Date
Write-Host ""
Write-Host "Execute undeploy with:"
Write-Host "   server = $server"
Write-Host "   database = $database"
Write-Host "   application = $application"
Write-Host "   version = $version"
Write-Host "   env = $env"
Write-Host "   logfile = $logfile"

$startDate = Get-Date
Write-Host "On" $startDate

$currentLoc = Get-Location
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$programFiles = ${env:programfiles(x86)}
if ($ProgramFiles -eq $null) { $programFiles = ${env:programfiles} }

# Log start
$startLogDate = Get-Date -format yyyyMMddhhmmss -ErrorAction:Stop
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$startLogDate;10;start undeploy of $application" 
}

# do some cleanup first
if (Get-PSDrive -Name BizTalk -ErrorAction:SilentlyContinue) { Remove-PSDrive -Name BizTalk -ErrorAction:SilentlyContinue }

# GroupRegistrationInfo
if (!(Get-Alias -Name 'GroupRegistrationInfo' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GroupRegistrationInfo' -Value "$BizTalkPSFolder\GroupRegistrationInfo.ps1"
}

if ($server -eq "SomeServer") {
# get the group registration info
# the variables $MgmtDBName and $MgmtDBServer
GroupRegistrationInfo
if (!($MgmtDBServer)) {
    Set-Location $currentLoc
    Write-Error "No BizTalk group info available" 
    Throw "No BizTalk group info available" 
    exit
}
$server = $MgmtDBServer
$database = $MgmtDBName
Write-Host "   server = $server"
Write-Host "   database = $database"
}

# map the biztalk drive
if (!(get-pssnapin | where-object { $_.Name -eq 'BizTalkFactory.Powershell.Extensions' })) { 
    $InitializeDefaultBTSDrive = $false
    Add-PSSnapIn BizTalkFactory.PowerShell.Extensions
}
if (!(Get-PSDrive -Name BizTalk -ErrorAction:SilentlyContinue)) {
    New-PSDrive -Name BizTalk -Root BizTalk:\ -PSProvider BizTalk -Instance $server -Database $database -ErrorAction:Stop | Out-Null
}

# Get the list of dependent applications
if (!(Get-Alias -Name 'GetApplicationDependencies' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GetApplicationDependencies' -Value "$BizTalkToolsFolder\GetBTSApplicationDependencies.exe"
}
# Stop application
if (!(Get-Alias -Name 'StopApplication' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'StopApplication' -Value "$BizTalkPSFolder\StopApplication.ps1"
}

# Is the application available?
Set-Location BizTalk:\Applications -ErrorAction:Stop
$app = Get-ChildItem | Where-Object { $_.Name -eq $application }
if ($app -eq $null) {
	Set-Location $currentLoc
	$endDate = Get-Date
	Write-Host $application "was not deployed"
	Write-Host "UnDeploy finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
	Write-Host ""
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);27;undeploy finished for $application (was not deployed)" 
    }
    exit
}
if ($version -and $app.Description -ne $version) {
	Set-Location $currentLoc
	$endDate = Get-Date
	Write-Host "The deployed version" $app.Description "does not match the given version" $version "for the application" $application
	Write-Host "UnDeploy finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
	Write-Host ""
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);27;undeploy finished for $application (version mismatch)" 
    }
    exit
}

# GetServersInGroup
if (!(Get-Alias -Name 'GetServersInGroup' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GetServersInGroup' -Value "$BizTalkPSFolder\GetServersInGroup.ps1"
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

# Get the servers belonging to the group
Set-Location $currentLoc
Write-Host "Get application servers for" $server "..."
$servers = GetServersInGroup -server $server -database $database
if ($servers.GetType().Name -eq "String") {
$appserver = $servers + ".$BizTalkDomain"
} else {
$appserver = $servers[0] + ".$BizTalkDomain" }

# We need to stop it first!
Set-Location $currentLoc
Write-Host ""
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);11;start stop for $application" 
}
StopApplication -server:$server -database:$database -application:$app.Name -env:$env -version:$version -logfile:$logfile -ErrorAction:SilentlyContinue -ErrorVariable:myError
if ($myError -ne $null) {
    if ($myError.Count -gt 0) {
    Set-Location $currentLoc
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);16;stop failed for $application : $myError[0]" 
    }
    Throw "Failed to stop $application : $myError[0]"
    exit
    }
}
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);18;end stop for $application" 
}

Set-Location BizTalk:\Applications -ErrorAction:Stop

# We need to remove the dependent applications first
# - Export and save current bindings
# - Export msi

# Get list list of dependent applications
Write-Host ""
Write-Host "Removing the dependent applications:"
Write-Host "Get Application Dependencies for" $application 
$apps = GetApplicationDependencies $application -server:$server -database:$database
if ($apps.Trim().Length -gt 0) {

$Applications = $apps -Split ','
Write-Host "Found the following Application Dependencies: ("$Applications.Length")" $Applications 
Write-Host ""

$appDir = "$BizTalkLogsFolder\Deployment\Export\" + $application
if ($Applications.Length -gt 0) {
    # We need to create a directory for storing the export bindings and msi's
    if (!(Get-Item "$BizTalkLogsFolder\Deployment\Export" -ErrorAction:SilentlyContinue)) {
        New-Item "$BizTalkLogsFolder\Deployment\Export" -type Directory
    }
    if (!(Get-Item $appDir -ErrorAction:SilentlyContinue)) {
        New-Item $appDir -type Directory
    }
    Remove-Item -Recurse -Force $appDir
}

# We need to stop the dependent applications first
$loopcnt = 0
while ($Applications -ne $null -and $Applications.Length -ne 0 -and $loopcnt -le 50)
{
    # Errorhandling here
    trap [BizTalkFactory.Management.Automation.BtsException]
    {
        # Set parent variable to indicate an error has occured.
        Write-Host "Failed to remove application"
        Write-Error $_.Exception.Message
        Set-Variable -Name ErrorOccured -Value  $true -Scope 1
        continue;
    }
   
    $ErrorOccured = $false

    # Prevent endless loop
    $loopcnt = $loopcnt + 1
    
    # Export the first item from the array.
    $d = Get-ItemProperty -Path $Applications[0] -Name Description
    $version = $d.Description
    Write-Host "Trying to save application: "  $Applications[0] " with version " $version
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);20;start save application : $Applications[0]" 
    }
    $appBinding = $appDir + '\' + $Applications[0] + '_' + $version + '.xml'
    #Export-Bindings -Path $Applications[0] -Destination $appBinding
    BTSTask ExportBindings -Destination:$appBinding -ApplicationName:$Applications[0] -Server:$server -Database:$database | Out-Host
    $appPackage = $appDir + '\' + $Applications[0] + '_' + $version + '.msi'
    #Export-Application -Path $Applications[0] -Package $appPackage
    BTSTask ExportApp -ApplicationName:$Applications[0] -Package:$appPackage -Server:$server -Database:$database | Out-Host
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);21;end save application : $Applications[0]" 
    }

    # Remove the first item from the array.
    Write-Host "Trying to remove application: "  $Applications[0]
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);22;start remove application : $Applications[0]" 
    }
    BTSTask RemoveApp -ApplicationName:$Applications[0] -Server:$server -Database:$database | Out-Host
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);23;end remove application : $Applications[0]" 
    }
    
    # Check if an error has occured.    
    if ($ErrorOccured)
    {
        # An error has occured. Put failed BtsApplication at the end of the array.
        $Applications = $Applications[1..($Applications.length - 1) + 0]
    }
    else
    {
        # Remove-Item was ok. Remove BtsApplication now also from the array or
        # if this was the last item set the array to null.
        if ($Applications.length -eq 1)
        {
            # Set the array to null.
            $Applications = $null
        }
        else
        {
            # Remove the item from the array.
            $Applications = $Applications[1..($Applications.length - 1)]
        }
    }
}

if ($loopcnt -gt 50) {
	Set-Location $CurrentLoc
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);24;failed to remove the dependent applications" 
    }
    Throw "Failed to remove the dependent applications for $application"
}

}
Write-Host "Done removing the dependent applications."

Write-Host ""
Write-Host "Removing application $application ..."

# Remove application
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);25;start remove application : $application" 
}
#BTSTask RemoveApp -ApplicationName:"$application" -Server:$server -Database:$database | Out-Host
Invoke-Command -ComputerName:$appserver -FilePath:"$BizTalkPSFolder\RemoveApplication.ps1" -ArgumentList:$server, $database, $application, $logfile -ConfigurationName:Microsoft.Powershell32 -Authentication:CredSSP -Credential:$cred -ErrorAction:SilentlyContinue -ErrorVariable:myError
if ($LastExitCode  -ne 0) { 
    Set-Location $currentLoc
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);26;failed to remove application : $application" 
    }
    throw "Error removing $application" 
}

Set-Location $currentLoc

$endDate = Get-Date
Write-Host "UnDeploy finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""

if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);27;end undeploy application : $application" 
}
