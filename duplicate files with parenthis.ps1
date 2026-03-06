# 1.Set your path here
$targetPath = "D:\Backups\Juan Jose Paz\78443"

# Create a low-level FileSystem Object to bypass 260-char limits
$fso = New-Object -ComObject Scripting.FileSystemObject

# Get files using a method that handles long paths better
$allFiles = Get-ChildItem -Path $targetPath -File -Recurse -ErrorAction SilentlyContinue

foreach ($dupFile in $allFiles) {
    # Match the pattern: " (#)"
    if ($dupFile.Name -match '\s\(\d+\)') {
        
        # Calculate what the original name should be
        $originalFullName = $dupFile.FullName -replace '\s\(\d+\)', ''

        # Use the COM Object to check if the file exists (bypasses MAX_PATH)
        if ($fso.FileExists($originalFullName)) {
            
            # Get the original file object via COM to check size
            $originalFile = $fso.GetFile($originalFullName)
            
            # Compare sizes
            if ($dupFile.Length -eq $originalFile.Size) {
                try {
                    # Use the COM object to delete the duplicate
                    $fso.DeleteFile($dupFile.FullName, $true)
                    Write-Host "DELETED (LONG PATH): $($dupFile.Name)" -ForegroundColor Cyan
                } catch {
                    Write-Host "LOCKED: $($dupFile.Name) is in use." -ForegroundColor Yellow
                }
            }
        }
    }
}

Write-Host "Deep Scan Complete." -ForegroundColor Green