
param 
( 
    [Parameter(Mandatory=$true)] 
    [string]$server, 
    [Parameter(Mandatory=$true)] 
    [string]$database,
    [Parameter(Mandatory=$true)] 
    [string]$application,
    [Parameter(Mandatory=$false)] 
	[string]$logfile
)

Get-Date
Write-Host "Execute test deploy sso with:"
Write-Host "   server = $server"
Write-Host "   database = $database"
Write-Host "   application = $application"
Write-Host "   logfile = $logfile"

$startDate = Get-Date -ErrorAction:Stop
Write-Host "On Date:" $startDate
Write-Host "On Server:" $env:computername

$currentLoc = Get-Location
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

if ($BizTalkPSFolder -eq $null) { $BizTalkPSFolder = 'D:\BizTalk\Powershell' }
if ($BizTalkToolsFolder -eq $null) { $BizTalkToolsFolder = 'D:\BizTalk\Tools' }
if ($BizTalkDomain -eq $null) { $BizTalkDomain = 'lonalo.local' }

# Get the credentials
$cred = $host.ui.PromptForCredential("Need credentials", "Please enter your user name and password.", $username, "")
if ($cred -eq $null) { exit }

$username = $cred.UserName
$startLogDate = Get-Date -format yyyyMMddhhmmss -ErrorAction:Stop

# GroupAvailable
if (!(Get-Alias -Name 'GroupAvailable' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GroupAvailable' -Value "$BizTalkPSFolder\GroupAvailable.ps1"
}
# GetServersInGroup
if (!(Get-Alias -Name 'GetServersInGroup' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GetServersInGroup' -Value "$BizTalkPSFolder\GetServersInGroup.ps1"
}
# GetSSOServerInGroup
if (!(Get-Alias -Name 'GetSSOServerInGroup' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'GetSSOServerInGroup' -Value "$BizTalkPSFolder\GetSSOServerInGroup.ps1"
}

# We need to deploy the sso files belonging to this app

# Before we continue, the group has to be operational 
# (all registrered servers must be up and running)
Write-Host "Check availability for group on" $server "..."
if (!(GroupAvailable -server:$server -database:$database)) {
    Write-Error "Deployment to $server and $database is not possible" 
    Set-Location $currentLoc
    exit
}

# Log start
if ($logfile -ne "") { 
    New-Item $logfile -type file -force
    Add-Content $logfile -value "$application;$msi;$username;$env;$startLogDate;1;start install of $msi" 
}

# Get the servers belonging to the group
Write-Host "Get application servers for" $server "..."
$servers = GetServersInGroup -server $server -database $database
if ($servers.GetType().Name -eq "String") {
$appserver = $servers + ".$BizTalkDomain"
} else {
$appserver = $servers[0] + ".$BizTalkDomain" }

# Log after get servers
if ($logfile -ne "") { Add-Content $logfile -value "$application;$msi;$username;$env;$(Get-Date -format yyyyMMddhhmmss);2;after get servers" }

# Deploy locally or not
$deployLocal = $false
# Where to import (on the first registrered server of the group)
if ($servers.GetType().Name -eq "String") {
if ($env:computername.ToLower() -eq $servers.ToLower()) { $deployLocal = $true }
$appserver = $servers + ".$BizTalkDomain"
} else {
if ($env:computername.ToLower() -eq $servers[0].ToLower()) { $deployLocal = $true }
$appserver = $servers[0] + ".$BizTalkDomain" }

# Deploy SSO
# Get the SSO server for this group
#$ssoserver = GetSSOServerInGroup -server $server -database $database
$ssoserver = "lobizsqlprd01"
$appssoserver = $ssoserver + ".$BizTalkDomain"

# Log start deploy sso
if ($logfile -ne "") { Add-Content $logfile -value "$application;$msi;$username;$env;$(Get-Date -format yyyyMMddhhmmss);55;start deploy sso on $appssoserver" }

# Import application
if (!(Get-Alias -Name 'DeploySSO' -ErrorAction:SilentlyContinue)) {
    Set-Alias -Name 'DeploySSO' -Value "$BizTalkPSFolder\DeploySSO.ps1"
}

# deploy the sso application in the group
Write-Host "Invoke DeploySSO on" $appssoserver "..."
if ($BizTalkInstallFolder -eq $null) { $BizTalkInstallFolder = "\\$appserver\C$\Program Files (x86)\Generated by BizTalk" }
# loop files in SSO folder
$ssoFiles = Get-ChildItem "$BizTalkInstallFolder\$application\Resources\SSO"
foreach ($ssoFile in $ssoFiles) {
   $ssoApp = "$BizTalkInstallFolder\$application\Resources\SSO\" + $ssoFile
   if ($deployLocal) {
       DeploySSO -application:$application -ssoApp:$ssoApp -ErrorAction:SilentlyContinue -ErrorVariable:myError
   }
   else {
       Invoke-Command -ComputerName:$appssoserver -FilePath:"$BizTalkPSFolder\DeploySSO.ps1" -ArgumentList:$application, $ssoApp -ConfigurationName:Microsoft.Powershell32 -Authentication:CredSSP -Credential:$cred -ErrorAction:SilentlyContinue -ErrorVariable:myError
   }
   if ($myError -ne $null) {
       if ($myError.Count -gt 0) {
       # Log failure of deployment
       if ($logfile -ne "") { Add-Content $logfile -value "$application;$msi;$username;$env;$(Get-Date -format yyyyMMddhhmmss);59;DeploySSO failed $myError[0]" }
       $Host.UI.WriteErrorLine($myError[0])
       throw "DeploySSO on server $appssoserver failed for '$application'"
       exit
       }
   }
}

Set-Location $currentLoc
Write-Host "Deployment finished after" (Get-Date).subtract($startdate).TotalSeconds "seconds"

# Log end of deployment
if ($logfile -ne "") { Add-Content $logfile -value "$application;$msi;$username;$env;$(Get-Date -format yyyyMMddhhmmss);100;Install complete" }
