# --- CONFIGURATION ---
$targetPath = "D:\Takeout"

Write-Host "Cleaning up .json files..." -ForegroundColor Cyan
# Deletes all JSON files recursively
Get-ChildItem -Path $targetPath -Include *.json -Recurse | Remove-Item -Force

Write-Host "Removing empty folders..." -ForegroundColor Cyan
# Finds all directories, sorts by depth (deepest first), and removes them if they have no files
Get-ChildItem -Path $targetPath -Recurse -Directory | Sort-Object FullName -Descending | ForEach-Object {
    if ((Get-ChildItem -Path $_.FullName -Force | Select-Object -First 1).Count -eq 0) {
        Remove-Item -Path $_.FullName -Force
        Write-Host "Removed empty folder: $($_.FullName)" -ForegroundColor Gray
    }
}

Write-Host "Done! All JSONs and empty sub-folders have been cleared." -ForegroundColor Green