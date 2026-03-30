$root = "D:\"
$inbox = "D:\05 Inbox"

# The list of folders we MUST NOT move
$protected = @(
    "01 Work and Projects",
    "02 Library",
    "03 Media and Assets",
    "04 Archive",
    "05 Inbox",
    "System Volume Information",
    '$RECYCLE.BIN'
)

# Get everything sitting on the root of D:
Get-ChildItem -Path $root | ForEach-Object {
    if ($protected -notcontains $_.Name) {
        Write-Host "Moving to Inbox: $($_.Name)" -ForegroundColor Cyan
        try {
            Move-Item -LiteralPath $_.FullName -Destination $inbox -Force -ErrorAction Stop
        } catch {
            Write-Host "Skipped: $($_.Name) (File may be in use)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nRoot cleaned! Everything else is now in 05 Inbox." -ForegroundColor Green