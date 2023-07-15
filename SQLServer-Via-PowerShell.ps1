##for Azure AD with a service principal use 
##string ConnectionString = @"Data Source=contoso.database.windows.net; Authentication=Active Directory Password; Initial Catalog=testdb;  UID=bob@contoso.onmicrosoft.com; PWD=MyPassWord!";
##SqlConnection conn = new SqlConnection(ConnectionString);
##conn.Open();



$LogFileName = "DBUtils.log"

$LogFilePathName = "./Logs/" + [datetime]::Now.ToShortDateString().replace("/","-") + $LogFileName


function LogThis ()
{
    Param([Parameter(Mandatory=$true)]  [String]$message, [String]$Level = "Info" )
	$now= [DateTime]::Now
	Write-Output "$now : $message" | Out-File $LogFilePathName -append 
    Write-Host ($message) 
 }


Function Connect-ToSQLB ($dbServer, $db,$user, $Password)
{ 
    LogThis -message ("Connecting to " + $dbServer + ":" +
                    $db + " as $user ") 
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder["Data Source"] = $dbServer
    $builder["Initial Catalog"] = $db
    $builder["Connect Timeout"] = 30;
    $builder["User ID"] = $user
    $builder["Password"] = $password

    $SQLConnection = New-Object System.Data.SQLClient.SQLConnection
    $SQLConnection.ConnectionString = $builder.ConnectionString
    $SQLConnection.Open()
    return $SQLConnection
}


Function Connect-ToSQLI ($dbServer, $db)
{ 
    LogThis -message ("Connecting to " + $dbServer + ":" +
                    $db + " as $user ") 
    $builder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $builder["Data Source"] = $dbServer
    $builder["Initial Catalog"] = $db
    $builder["Connect Timeout"] = 30;
    $builder["Integrated Security"] = $true
    
    $SQLConnection = New-Object System.Data.SQLClient.SQLConnection
    $SQLConnection.ConnectionString = $builder.ConnectionString
    $SQLConnection.Open()
    return $SQLConnection
}

Function ExecuteSQL-Reader([string] $SQLCommand, $SQLConnection)
{
    $Datatable = New-Object System.Data.DataTable

    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $SQLConnection
    $Command.CommandText = $SQLCommand
    $Reader = $Command.ExecuteReader()
    $Datatable.Load($Reader)
    return $Datatable 
}

Function ExecuteSQL-Scalar([string] $SQLCommand, $SQLConnection)
{
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $SQLConnection
    $Command.CommandText = $SQLCommand
    $Reader = $Command.ExecuteScalar()
    return $Reader 
}


Function ExecuteSQL-NonQuery([string] $SQLCommand, $SQLConnection)
{
    $Command = New-Object System.Data.SQLClient.SQLCommand
    $Command.Connection = $SQLConnection
    $Command.CommandText = $SQLCommand
    $Reader = $Command.ExecuteNonQuery()
    return $Reader 
}
$sqlcon = Connect-ToSQLB -dbServer contoso.database.windows.net -db dmesg -user "sa" -Password "P@sssword!"

ExecuteSQL-Reader -SQLCommand "select @@version" -SQLConnection $sqlcon