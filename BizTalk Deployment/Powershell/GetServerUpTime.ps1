param 
( 
    [string]$computer = "SomeServer"
)

$lastboottime = (Get-WmiObject -Class Win32_OperatingSystem -computername $computer -ErrorAction:SilentlyContinue).LastBootUpTime
if ($lastboottime -ne $null) {
    $sysuptime = (Get-Date) – [System.Management.ManagementDateTimeconverter]::ToDateTime($lastboottime)
    $totalSeconds = $sysuptime.TotalSeconds
    }
else {
    Write-Error $computer "is not available!"
    $totalSeconds = 0 }

$totalSeconds