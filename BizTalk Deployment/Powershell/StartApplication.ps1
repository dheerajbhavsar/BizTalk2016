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

$currentLoc = Get-Location

Write-Host "Execute start with:"
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

# Log start
$startLogDate = Get-Date -format yyyyMMddhhmmss -ErrorAction:Stop
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$startLogDate;12;start $application" 
}

if ($server -eq "SomeServer") {
# get the group registration info
# the variables $MgmtDBName and $MgmtDBServer
.\GroupRegistrationInfo.ps1
if (!($MgmtDBServer)) {
    Set-Location $currentLoc
    Write-Error "No BizTalk group info available" 
    Throw "No BizTalk group info available" 
    exit
}
$server = $MgmtDBServer
$database = $MgmtDBName
}

# map the biztalk drive
if (!(get-pssnapin | where-object { $_.Name -eq 'BizTalkFactory.Powershell.Extensions' })) { 
    $InitializeDefaultBTSDrive = $false
    Add-PSSnapIn BizTalkFactory.PowerShell.Extensions
}
if (!(Get-PSDrive -Name BizTalk -ErrorAction:SilentlyContinue)) {
    New-PSDrive -Name BizTalk -Root BizTalk:\ -PSProvider BizTalk -Instance $server -Database $database -ErrorAction:Stop | Out-Null
}

# Is the application deployed?
Set-Location BizTalk:\Applications -ErrorAction:Stop
$app = Get-ChildItem | Where-Object { $_.Name -eq $application }
if ($app -eq $null) {
	Set-Location $CurrentLoc
	$endDate = Get-Date
	Write-Host $application "was not deployed"
	Write-Host "Start finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
	Write-Host ""
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);18;start finished for $application (was not deployed)" 
    }
	exit
}
if ($version -and $app.Description -ne $version) {
	Set-Location $currentLoc
	$endDate = Get-Date
	Write-Host "The deployed version" $app.Description "does not match the given version" $version "for the application" $application
	Write-Host "Start finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
	Write-Host ""
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);18;start finished for $application (version mismatch)" 
    }
    exit
}
if ($app.Status -eq 'Started') {
	Set-Location $CurrentLoc
    $endDate = Get-Date
    Write-Host "The application" $application "is already started"
	Write-Host "Start finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);18;start finished for $application (already started)" 
    }
	exit
}

# Start the application
Write-Host "Starting $application ..."
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);15;start start for $application" 
}
Write-Host "DeployAllPolicies"
Start-Application -Path $application -StartOption DeployAllPolicies -ErrorAction:SilentlyContinue -ErrorVariable:myError
if ($myError.Count -eq 0) {
    Write-Host "StartAllSendPorts"
    Start-Application -Path $application -StartOption StartAllSendPorts -ErrorAction:SilentlyContinue -ErrorVariable:myError
}
if ($myError.Count -eq 0) {
    Write-Host "StartAllSendPortGroups"
    Start-Application -Path $application -StartOption StartAllSendPortGroups -ErrorAction:SilentlyContinue -ErrorVariable:myError
}
if ($myError.Count -eq 0) {
    Write-Host "StartAllOrchestrations"
    Start-Application -Path $application -StartOption StartAllOrchestrations -ErrorAction:SilentlyContinue -ErrorVariable:myError
}
if ($myError.Count -eq 0) {
    Write-Host "EnableAllReceiveLocations"
    Start-Application -Path $application -StartOption EnableAllReceiveLocations -ErrorAction:SilentlyContinue -ErrorVariable:myError
}

Set-Location $CurrentLoc

if ($myError.Count -gt 0) {
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);16;failed to start the application : $application" 
    }
    Throw "Failed to start $application: $myError[0]"
}

$endDate = Get-Date
Write-Host "Start finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""
if ($logfile -ne "") { 
    Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);18;start finished for $application" 
}
