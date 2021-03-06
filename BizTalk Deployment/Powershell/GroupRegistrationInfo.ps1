$server = $null
$database = $null

if (test-path "HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration") 
{
   $root = "HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration"
   if (Get-PSDrive -name BizAdmin -ErrorAction:SilentlyContinue) { Remove-PSDrive -name BizAdmin }
   New-PSDrive -name BizAdmin -psprovider Registry -root $root -ErrorAction:Stop | Out-Null

   $server = $(Get-ItemProperty -Path BizAdmin:).MgmtDBServer
   $database = $(Get-ItemProperty -Path BizAdmin:).MgmtDBName
}

Set-Variable MgmtDBServer $server -Scope global
Set-Variable MgmtDBName $database -Scope global
