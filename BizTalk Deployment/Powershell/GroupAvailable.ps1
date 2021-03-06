param 
( 
    [string]$server = "SomeServer", 
    [string]$database = "SomeDatabase"
)

$groupStatus = $false
$servers = .\GetServersInGroup.ps1 -server:$server -database:$database
if ($servers.GetType().Name -eq "String") { $serversCnt = 1
} else {
$serversCnt = $servers.Count }
Write-Debug "# servers in group = $serverscnt"
$serversUp = 0
foreach ($s in $servers) { if ((.\GetServerUpTime.ps1 -computer $s) -gt 0) { $serversUp++  } }
Write-Debug "# servers available in group = $serversUp"
if ($serversCnt -eq $serversUp) { $groupStatus = $true }
$groupStatus
