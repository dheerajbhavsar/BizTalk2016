<#
.SYNOPSIS
Copyright (c) bizilante 2018. All rights reserved.
Deploy to SSO config store.
.DESCRIPTION
Import the SSO file
.PARAMETER application
Name of the SSO application
.PARAMETER ssoApp
The file containing the SSO key/value settings
.INPUTS
.OUTPUTS
.EXAMPLE
DeploySSO.ps1 [-application] <string> [-ssoApp] <string> [<CommonParameters>]
.NOTES
<drive>:\BizTalk\Tools\DeploySSO.exe must be available on the computer where the script is executed.
bizilante SSO Application Deployment Utility Version 3.2.0.0
Copyright (c) 2016 bizilante nv. All rights reserved.

Deploy: Imports a SSO ConfigStore into the SSO configuration database.

Usage:
  Deploy [-NonEncryptedFile:value] [-CompanyName:value] [-Server:value] [-Database:value] [-Timeout:value]

Parameters:
  -NonEncryptedFile  Required. SSO XML file
  -CompanyName       Required. Company name used to the SSO values.
  -Server            Optional. The name of SQL server hosting the SSO configuration database.
  -Database          Optional. The name of the SSO configuration database.
  -Timeout           Optional. Transaction timeout value (in seconds)

Example:
  Deploy -NonEncryptedFile:"C:\Temp\MyApp.xml" -CompanyName:bizilante

Notes:
  File must exist.
  Parameter names are not case-sensitive and may be abbreviated.
#>
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
$file = (Get-ChildItem "$DeploySSO" -ErrorAction:SilentlyContinue)
if (!$file.Exists) {
	$DeploySSO = "D:\BizTalk\Tools\DeploySSO.exe"
	$file = (Get-ChildItem "$DeploySSO" -ErrorAction:SilentlyContinue)
	if (!$file.Exists) {
		$DeploySSO = "E:\BizTalk\Tools\DeploySSO.exe"
	}
}
$file = (Get-ChildItem "$DeploySSO" -ErrorAction:SilentlyContinue)
if (!$file.Exists) {
	throw "<drive>:\BizTalk\Tools\DeploySSO.exe not found"
}
$arguments = "-NonEncryptedFile:$ssoApp"

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