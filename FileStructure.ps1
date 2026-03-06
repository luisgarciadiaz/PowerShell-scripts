# Define the root path and output file
$rootPath = Get-Location
$htmlFile = "$env:TEMP\FolderList.html"
$pdfFile = "$rootPath\FolderStructure.pdf"

# Function to recursively get folders
function Get-FolderStructure {
    param ([string]$path, [int]$depth = 0)
    
    $results = @()
    $items = Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue

    foreach ($item in $items) {
        # Create visual hierarchy using dashes
        $indent = "-" * $depth
        $results += "$indent $($item.Name)"
        
        # Recursive call to get subfolders
        $subFolders = Get-FolderStructure -path $item.FullName -depth ($depth + 2)
        
        if ($subFolders) {
            $results += $subFolders
        }
    }
    return $results
}

Write-Host "Scanning folders... this may take a moment." -ForegroundColor Cyan
$folderData = Get-FolderStructure -path $rootPath

# Convert the list to HTML
$htmlContent = @"
<html>
<head>
    <style>
        body { font-family: 'Segoe UI', 'Courier New', monospace; line-height: 1.4; padding: 40px; }
        h2 { border-bottom: 2px solid #333; padding-bottom: 10px; color: #2c3e50; }
        .folder-list { white-space: pre; font-size: 13px; color: #444; }
    </style>
</head>
<body>
    <h2>Folder Structure: $($rootPath.Path)</h2>
    <div class="folder-list">$($folderData -join "`n")</div>
</body>
</html>
"@

$htmlContent | Out-File -FilePath $htmlFile -Encoding utf8

# Use Edge to print to PDF
Write-Host "Generating PDF via Microsoft Edge..." -ForegroundColor Green
Start-Process "msedge" -ArgumentList "--headless --disable-gpu --print-to-pdf=`"$pdfFile`" `"$htmlFile`"" -Wait

# Cleanup
if (Test-Path $htmlFile) { Remove-Item $htmlFile }
Write-Host "Done! Check your folder for: FolderStructure.pdf" -ForegroundColor Yellow