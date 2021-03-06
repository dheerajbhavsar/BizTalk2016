
param 
( 
    [Parameter(Mandatory=$true)] 
    [string]$application,
    [Parameter(Mandatory=$true)] 
    [string]$itinerary
)

$startDate = Get-Date

Write-Host "Execute DeployItinerary with:"
Write-Host "   application = $application"
Write-Host "   sso script = $itinerary"
Write-Host "On" $startDate

$currentLoc = Get-Location

# DeploySSO
$EsbImportUtil = "C:\Program Files (x86)\Microsoft BizTalk ESB Toolkit\Bin\Esbimportutil.exe"

# Is there a itinerary to deploy
$file = (Get-ChildItem "$itinerary" -ErrorAction:SilentlyContinue)
if (!$file.Exists) {
    Write-Host "For the application $application, the $itinerary file could not be located!"
    exit
}

Write-Host "Deploying itinerary for application $application ..."

# Deploy the SSO file (the encrypted file can contains spaces)
&$EsbImportUtil /f:"$itinerary" /c:deployed /o | Out-Host
if ($LastExitCode  -ne 0) { throw "Error deploying itinerary for $application" }

$endDate = Get-Date
Write-Host "Deploy Itinerary finished on" $endDate "and took" $endDate.Subtract($startDate).TotalSeconds "seconds"
Write-Host ""