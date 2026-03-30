$root = "D:\"
# This automatically puts the report inside the folder being scanned
$output = Join-Path -Path $root -ChildPath "FolderTree.txt"
$rootPath = (Get-Item -LiteralPath $root).FullName

$title = "File Count"
$message = "Do you want to list how many files are inside each folder?"
$options = [System.Management.Automation.Host.ChoiceDescription[]] @(
    New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Show file counts/names."
    New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Show only folder names."
)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

# Initialize Counters
$totalFilesFound = 0
$emptyFoldersCount = 0
$oneFileFoldersCount = 0

Write-Host "Scanning..." -ForegroundColor Cyan
$allFolders = Get-ChildItem -LiteralPath $rootPath -Recurse -Directory -ErrorAction SilentlyContinue | Sort-Object FullName
$totalFolders = $allFolders.Count
$current = 0

$results = foreach ($folder in $allFolders) {
    $current++
    Write-Progress -Activity "Creating Folder List" -Status "Processing: $($folder.Name)" -PercentComplete (($current / $totalFolders) * 100)
    
    $relativePath = $folder.FullName.Substring($rootPath.Length)
    $depth = ($relativePath.Split([System.IO.Path]::DirectorySeparatorChar, [System.StringSplitOptions]::RemoveEmptyEntries)).Count
    $line = ("-" * ($depth - 1)) + $folder.Name

    if ($result -eq 0) {
        $files = Get-ChildItem -LiteralPath $folder.FullName -File -ErrorAction SilentlyContinue
        $fileCount = $files.Count
        $totalFilesFound += $fileCount
        
        if ($fileCount -gt 1) {
            $line += " has $fileCount files"
        } elseif ($fileCount -eq 1) {
            $line += " - $($files[0].Name)"
            $oneFileFoldersCount++
        } else {
            $line += " (empty)"
            $emptyFoldersCount++
        }
    }
    $line
}

# Save report
$results | Out-File -FilePath $output -Encoding utf8

# Final Output to Console
Write-Progress -Activity "Creating Folder List" -Completed
Write-Host "`n--- Scan Summary ---" -ForegroundColor Yellow
Write-Host "Total Folders Scanned: $totalFolders"
if ($result -eq 0) {
    Write-Host "Total Files Found:     $totalFilesFound"
    Write-Host "Empty Folders:         $emptyFoldersCount"
    Write-Host "Folders with 1 file:   $oneFileFoldersCount"
}
[System.Console]::Beep()

Write-Host "Report saved to: $output" -ForegroundColor Green