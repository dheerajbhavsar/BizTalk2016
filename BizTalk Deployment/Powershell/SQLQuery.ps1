
param 
( 
    [string]$Server = "SomeServer", 
    [string]$Database = "SomeDatabase",
    [string]$Query 
)

$SqlServer = $Server
$SqlCatalog = $Database
if ($query) { $SqlQuery = $query } else {
$SqlQuery = read-host "Please Enter a Query for the Scheduler" }
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection
$SqlConnection.ConnectionString = "Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True"
Write-Debug "ConnectionString= 'Server = $SqlServer; Database = $SqlCatalog; Integrated Security = True'"
Write-Debug "Query= '$SqlQuery'"
$SqlCmd = New-Object System.Data.SqlClient.SqlCommand
$SqlCmd.CommandText = $SqlQuery
$SqlCmd.Connection = $SqlConnection
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SqlCmd
$DataSet = New-Object System.Data.DataSet
$rowsCnt = $SqlAdapter.Fill($DataSet)
$SqlConnection.Close()
Clear
$DataSet.Tables[0]