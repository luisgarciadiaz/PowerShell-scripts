$root = "G:\My Drive"
if (-not (Test-Path $root)) { $root = "G:\Mi unidad" }
$output = "$home\Desktop\Full_GoogleDrive_Tree.txt"

if (-not (Test-Path $root)) {
    Write-Host "Error: Cannot find Google Drive root." -ForegroundColor Red
    return
}

$title = "File Count"
$message = "Do you want to list how many files are inside each folder?"
$options = [System.Management.Automation.Host.ChoiceDescription[]] @(
    New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Show file counts/names."
    New-Object System.Management.Automation.Host.ChoiceDescription "&No", "Show only folder names."
)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

Write-Host "Scanning full Google Drive... (This will take a while)" -ForegroundColor Cyan

# Grabs the root and all sub-folders safely
$allFolders = @(Get-Item -LiteralPath $root -ErrorAction SilentlyContinue) + @(Get-ChildItem -LiteralPath $root -Recurse -Directory -ErrorAction SilentlyContinue)
Write-Host "Done Scanning" -ForegroundColor Cyan
$results = foreach ($folder in $allFolders) {
    $relativePath = $folder.FullName.Replace($root, "")
    $depth = ($relativePath.Split([System.IO.Path]::DirectorySeparatorChar, [System.StringSplitOptions]::RemoveEmptyEntries)).Count
    $line = ("-" * $depth) + $folder.Name

    if ($result -eq 0) {
        $files = @(Get-ChildItem -LiteralPath $folder.FullName -File -ErrorAction SilentlyContinue)
        if ($files.Count -gt 1) {
            $line += " has $($files.Count) files"
        } elseif ($files.Count -eq 1) {
            $line += " - $($files[0].Name)"
        } else {
            $line += " (empty)"
        }
    }
    $line
}

$results | Out-File -FilePath $output -Encoding utf8
Write-Host "Report saved to: $output" -ForegroundColor Green