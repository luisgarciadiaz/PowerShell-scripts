# Get every subfolder on D:, sorted by depth so we rename children before parents
$allFolders = Get-ChildItem -Path "D:\" -Directory -Recurse -ErrorAction SilentlyContinue | Sort-Object {$_.FullName.Length} -Descending

foreach ($folder in $allFolders) {
    # Check if the folder name contains brackets like [01] or [Anything]
    if ($folder.Name -match '\[.*\]') {
        # Create the new name by removing [ and ]
        $newName = $folder.Name -replace '\[|\]', ''
        
        Write-Host "Renaming: $($folder.FullName) -> $newName" -ForegroundColor Cyan
        
        try {
            # Use LiteralPath to ensure the brackets are handled correctly
            Rename-Item -LiteralPath $folder.FullName -NewName $newName -ErrorAction Stop
        } catch {
            Write-Host "Skipped: $($folder.Name) (Folder might be in use)" -ForegroundColor Yellow
        }
    }
}

Write-Host "`nAll nested folders have been processed!" -ForegroundColor Green