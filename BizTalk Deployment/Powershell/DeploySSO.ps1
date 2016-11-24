
param 
( 
    [Parameter(Mandatory=$true)] 
    [string]$application,
    [Parameter(Mandatory=$true)] 
    [string]$ssoApp
)

$startDate = Get-Date

Write-Host "Execute DeploySSO with:"
Write-Host "   application = $application"
Write-Host "   sso script = $ssoApp"
Write-Host "On" $startDate

$currentLoc = Get-Location

# DeploySSO
$DeploySSO = "C:\BizTalk\Tools\DeploySSO.exe"
$arguments = "-EncryptedFile:$ssoApp"

# Is there a SSO app to deploy
$file = (Get-ChildItem "$ssoApp" -ErrorAction:SilentlyContinue)
if (!$file.Exists) {
#if (!(Test-Path -Path '$ssoApp')) {
    Write-Host "The application $application has no SSO configured: $ssoApp could not be located!"
    exit
}

Write-Host "Deploying SSO application $application ..."

# Deploy the SSO file (the encrypted file can contains spaces)
&$DeploySSO Deploy -EncryptionKey:BizTalk $arguments | Out-Host
if ($LastExitCode  -ne 0) { throw "Error deploying SSO for $application" }

$endDate = Get-Date
Write-Host "Deploy SSO finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""