# 1. Define the folder you want to clean (Change this path)
$targetFolder = "D:\TakoutFixed"


Add-Type -AssemblyName System.Drawing

# Expanded list of extensions
$extensions = "*.jpg", "*.jpeg", "*.png", "*.bmp", "*.webp", "*.gif"
$files = Get-ChildItem -Path $targetFolder -Include $extensions -Recurse

foreach ($file in $files) {
    try {
        # Check for 0KB files first (Google Photos also rejects these)
        if ($file.Length -eq 0) {
            Write-Host "Deleting empty file: $($file.Name)" -ForegroundColor Magenta
            Remove-Item -Path $file.FullName -Force
            continue
        }

        $img = [System.Drawing.Image]::FromFile($file.FullName)
        $w = $img.Width
        $h = $img.Height
        $img.Dispose() # Kill the process link immediately

        if ($w -lt 256 -or $h -lt 256) {
            Write-Host "Deleting small image: $($file.Name) ($w x $h)" -ForegroundColor Yellow
            Remove-Item -Path $file.FullName -Force
        }
    }
    catch {
        # This catches files that are technically images but 'corrupt' or unreadable
        Write-Host "Forcing deletion of unreadable image: $($file.Name)" -ForegroundColor Red
        Remove-Item -Path $file.FullName -Force
    }
}

Write-Host "Cleanup complete. Please restart Google Drive." -ForegroundColor Green