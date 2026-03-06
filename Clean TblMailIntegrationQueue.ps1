
# Define SQL Server connection details
$ServerInstance = "YOUR_SERVER_NAME"
$Database = "YOUR_DATABASE_NAME"
$Table= "YOURTABLE"

# SQL command to delete rows in batches of 100
$sqlCommand = @"
SET NOCOUNT ON;

WHILE EXISTS (SELECT 1 FROM $Table)
BEGIN
    ;WITH cte AS (
        SELECT TOP (100) *
        FROM $Table
    )
    DELETE FROM cte;

    PRINT 'Deleted 100 oldest rows...';
    WAITFOR DELAY '00:00:01';
END
"@

try {
    Write-Host "Starting cleanup process..."
    Invoke-Sqlcmd -ServerInstance $ServerInstance -Database $Database -Query $sqlCommand
    Write-Host "Cleanup completed successfully."
}
catch {
    Write-Host "Error occurred: $($_.Exception.Message)"
}
