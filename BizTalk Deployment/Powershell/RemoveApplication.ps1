
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
Write-Host ""
Write-Host "Execute remove application with:"
Write-Host "   server = $server"
Write-Host "   database = $database"
Write-Host "   application = $application"
Write-Host "   logfile = $logfile"

$startDate = Get-Date
Write-Host "On" $startDate

$currentLoc = Get-Location
$username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$programFiles = ${env:programfiles(x86)}
if ($ProgramFiles -eq $null) { $programFiles = ${env:programfiles} }

BTSTask RemoveApp -ApplicationName:"$application" -Server:$server -Database:$database | Out-Host
if ($LastExitCode  -ne 0) { 
    Set-Location $currentLoc
    if ($logfile -ne "") { 
        Add-Content $logfile -value "$application;;$username;$env;$(Get-Date -format yyyyMMddhhmmss);26;failed to remove application : $application" 
    }
    throw "Error removing $application" 
}

Set-Location $currentLoc

$endDate = Get-Date
Write-Host "Remove Application finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""
